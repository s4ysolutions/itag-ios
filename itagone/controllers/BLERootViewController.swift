//
//  ViewController.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import BLE
import UIKit
import Rasat
import WayTodaySDK
import CoreLocation

class BLERootViewController: UIViewController {
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var soundButton: UIButton?
    @IBOutlet weak var waytodayLed: UIImageView?
    
    static let imageNoSound = UIImage(named: "itemNoSound")
    static let imageSound = UIImage(named: "itemSound")
    static let imageVibration = UIImage(named: "itemVibration")
    static let imageLedBlue = UIImage(named: "ledBlue")
    static let imageLedGreen = UIImage(named: "ledGreen")
    static let imageLedGray = UIImage(named: "ledGray")
    static let imageLedRed = UIImage(named: "ledRed")
    static let imageLedYellow = UIImage(named: "ledYellow")
    
    let ble: BLEInterface
    let store: TagStoreInterface
    
    var contentID = ""
    var disposable: DisposeBag?
    
    private let locationService: LocationService
    private var waytoday: WayTodayState
    private var waytodayService: WayTodayService
    private var uploader: Uploader
    
    var blueLedIsOn = false;
    var greenLedIsOn = false;
    var redLedIsOn = false;
    
    required init?(coder aDecoder: NSCoder) {
        ble = BLEDefault.shared
        store = TagStoreDefault.shared
        waytoday = WayTodayStateDefault.shared
        locationService = LocationServiceDefault.shared(log: LogDefault.shared, wayTodayState: waytoday)
        waytodayService = WayTodayServiceDefault.shared(log: LogDefault.shared, wayTodayState: waytoday, appname: WAYTODAY_APPNAME, secret: WAYTODAY_SECRET, provider: WAYTODAY_PROVIDER)
        uploader = UploaderDefault.shared(log: LogDefault.shared, wayTodayState: waytoday)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupItemSound()
    }
    
    private func setLedNone() {
        if waytoday.on {
            if locationService.authorizationStatus == .Authorized {
                if locationService.status == .started {
                    self.waytodayLed?.image = BLERootViewController.imageLedYellow
                } else {
                    self.waytodayLed?.image = BLERootViewController.imageLedGray
                }
            } else {
                self.waytodayLed?.image = BLERootViewController.imageLedRed
            }
        } else {
            self.waytodayLed?.image = BLERootViewController.imageLedGray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        disposable?.dispose()
        disposable = DisposeBag()
        disposable!.add(store.observable.subscribe(on: DispatchQueue.main, id: "tag_change_root", handler: {_ in
            self.setupContent()
        }))
        setLedNone()
        // update led on new location
        disposable!.add(locationService.observableLocation.subscribe(on: DispatchQueue.global(qos: .userInteractive), handler: {
            location in
            if (self.greenLedIsOn || self.blueLedIsOn || self.redLedIsOn) {
                return
            }
            self.greenLedIsOn = true
            DispatchQueue.main.sync(execute: {
                self.waytodayLed?.image = BLERootViewController.imageLedGreen
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                self.setLedNone()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                    self.greenLedIsOn = false
                })
            })
        }))
        // update leds on upload
        disposable!.add(uploader
            .observableState
            .subscribe(id:"uploadedController", handler: {uploaderState in
                DispatchQueue.main.async {
                    switch(uploaderState){
                    case UploaderState.UPLOADING:
                        if (self.blueLedIsOn) {
                            return
                        }
                        self.blueLedIsOn = true
                        self.greenLedIsOn = false
                        self.redLedIsOn = false
                        self.waytodayLed?.image = BLERootViewController.imageLedBlue
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                            self.setLedNone()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                                self.blueLedIsOn = false
                            })
                        })
                    case UploaderState.ERROR:
                        if (self.redLedIsOn) {
                            return
                        }
                        self.redLedIsOn = true
                        self.waytodayLed?.image = BLERootViewController.imageLedRed
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                            self.setLedNone()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                                self.redLedIsOn = false
                            })
                        })
                    default:
                        self.setLedNone()
                    }
                }
            })
        )
        
        disposable!.add(locationService.observableLocation.subscribe(on: DispatchQueue.global(qos: .userInteractive), handler: {
            location in
            if (self.greenLedIsOn) {
                return
            }
            self.greenLedIsOn = true
            DispatchQueue.main.sync(execute: {
                self.waytodayLed?.image = BLERootViewController.imageLedGreen
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                self.setLedNone()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                    self.greenLedIsOn = false
                })
            })
        }))
        
        disposable!.add(waytoday.observableOn.subscribe(handler: {_ in
            DispatchQueue.main.async{
                self.setLedNone()
            }
        }))
        
        setupContent()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        disposable?.dispose()
        super.viewWillDisappear(animated)
    }
    
    @IBAction
    func sound(_ sender: UIView) {
        AlertSoundPreferences.next()
        setupItemSound()
    }
    
    private func setupItemSound() {
        let image = { () -> UIImage? in
            switch AlertSoundPreferences.mode {
            case .NoSound:
                return BLERootViewController.imageNoSound
            case .Sound:
                return BLERootViewController.imageSound
            case .Vibration:
                return BLERootViewController.imageVibration
            }
        }()
        
        soundButton?.setImage( image, for: .normal)
    }
    
    @IBAction
    func onWayToday(_ sender: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if waytoday.tid != "" {
            alert.addAction(UIAlertAction(title: String(format: "Your ID: %@. Click to change".localized, waytoday.tid), style: .default) { _ in
                self.requestTid(complete: {_ in })
            })
            
            alert.addAction(UIAlertAction(title: String(format: "Show you recent positions on the map".localized, waytoday.tid), style: .default) { _ in
                guard let url=URL(string: "https://way.today/#\(self.waytoday.tid)!10") else {
                    return //be safe
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            })
            
            alert.addAction(UIAlertAction(title: String(format: "Share your position".localized, waytoday.tid), style: .default) { _ in
                guard let url=URL(string: "https://way.today/#\(self.waytoday.tid)!10") else {
                    return //be safe
                }
                
                // set up activity view controller
                let textToShare = [ url ] as [Any]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.openInIBooks]
                
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
            })
            
        }
        
        alert.addAction(UIAlertAction(title: locationService.status == .started ? "Turn off WayToday".localized : "Turn on WayToday".localized , style: .default) { _ in
            self.toggleWayToday()
        })
        
        alert.addAction(UIAlertAction(title: "About WayToday".localized, style: .default) { _ in
            let alert = UIAlertController(title: "About WayToday".localized, message: "about_way_today_text".localized, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "More...".localized, style: .default, handler: { _ in
                guard let url=URL(string: "https://way.today/landing/en.html".localized) else {
                    return //be safe
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Close".localized, style: .default, handler: nil))
            
            self.present(alert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Close".localized, style: .default) { _ in
            
        })
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: sender.bounds.midX,
                                                  y: sender.bounds.midY,
                                                  width: sender.bounds.width,
                                                  height: sender.bounds.height)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func toggleWayToday() -> Void {
        if (self.waytoday.on) {
            self.waytoday.on = false
            uploader.reset()
        } else {
            if (store.hasAlerts) {
                uploader.reset()
                if (self.waytoday.tid == "") {
                    self.requestTid(complete: {_ in
                        if (self.waytoday.tid != "") {
                            self.waytoday.on = true
                        }
                    })
                } else {
                    self.waytoday.on = true
                }
            } else {
                let alert = UIAlertController(title: "WayToday is not available".localized, message: "way_today_no_available_text".localized, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Install WayToday".localized, style: .default, handler: { _ in
                    guard let url=URL(string: "itms-apps://apps.apple.com/us/app/id1472679829") else {
                        return //be safe
                    }
                    print(url)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Close".localized, style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
            
        }
    }
    
    var gettingTid = false
    private func requestTid(complete: @escaping (_ tid: String) -> Void) {
        if gettingTid {
            return
        }
        gettingTid = true
        do {
            try waytodayService.generateTid(prevTid: waytoday.tid, complete: { tid in
                DispatchQueue.main.sync {
                    self.waytoday.tid = tid
                    self.gettingTid = false
                    complete(tid)
                }
            })
        }catch{
            gettingTid = false
            // TODO: handle error
            print(error)
        }
    }
    
    // MARK: - Manage Content
    
    func setupContent() {
        contentID = store.count == 0 ? "tags0" : store.count == 1 ? "tag1" : store.count == 2 ? "tags2" : store.count == 3 ? "tags3" : "tags4"
        guard let contentViewController = self.storyboard?.instantiateViewController(withIdentifier: contentID) else { return }
        guard let contentView = contentViewController.view else { return }
        
        while children.count > 0 {
            let child = children[0]
            child.willMove(toParent: self)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        addChild(contentViewController)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false;
        containerView?.addSubview(contentViewController.view)
        containerView?.addConstraint(NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy:NSLayoutConstraint.Relation.equal,
            toItem: containerView!,
            attribute:NSLayoutConstraint.Attribute.top,
            multiplier:1.0,
            constant: 0
        ))
        containerView?.addConstraint(NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy:NSLayoutConstraint.Relation.equal,
            toItem: containerView!,
            attribute:NSLayoutConstraint.Attribute.bottom,
            multiplier:1.0,
            constant: 0
        ))
        containerView?.addConstraint(NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutConstraint.Attribute.leading,
            relatedBy:NSLayoutConstraint.Relation.equal,
            toItem: containerView!,
            attribute:NSLayoutConstraint.Attribute.leading,
            multiplier:1.0,
            constant: 0
        ))
        containerView?.addConstraint(NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutConstraint.Attribute.trailing,
            relatedBy:NSLayoutConstraint.Relation.equal,
            toItem: containerView!,
            attribute:NSLayoutConstraint.Attribute.trailing,
            multiplier:1.0,
            constant: 0
        ))
        
        contentViewController.didMove(toParent: self)
    }
    
}

