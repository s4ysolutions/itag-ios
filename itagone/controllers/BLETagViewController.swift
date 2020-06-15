//
//  BLETagViewController.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import BLE
import Rasat
import UIKit
import CoreLocation
import MapKit

class BLETagViewController: UIViewController {
    @IBOutlet weak var buttonAlert: UIButton?
    @IBOutlet weak var buttonTagContainer: UIView?
    @IBOutlet weak var buttonTag: UIButton?
    @IBOutlet weak var labelName: UILabel?
    @IBOutlet weak var imageState: UIImageView?
    @IBOutlet weak var buttonLost: UIButton!
    
    static let imageBlack = UIImage(named: "tagBlack")
    static let imageBlue = UIImage(named: "tagBlue")
    static let imageGold = UIImage(named: "tagGold")
    static let imageGreen = UIImage(named: "tagGreen")
    static let imageRed = UIImage(named: "tagRed")
    static let imageWhite = UIImage(named: "tagWhite")
    
    static let imageConnecting = UIImage(named: "btConnecting")
    static let imageConnected = UIImage(named: "btConnected")
    static let imageDisabled = UIImage(named: "btDisabled")
    static let imageScanning = UIImage(named: "btScanning")
    static let imageSetup = UIImage(named: "btSetup")
    
    static let imageAlert = UIImage(named: "btnAlert")
    static let imageNoAlert = UIImage(named: "btnNoAlert")
    
    let ble: BLEInterface
    let sound = SoundDefault.shared
    let store: TagStoreInterface
    
    var disposable: DisposeBag? = nil
    var tag: TagInterface?
    
    let log = Logger("Tag View")
    let lc = Logger("Tag View Life cicle")
    
    var alertState: Bool {
        get {
            guard let tag = tag else { return false}
            return tag.alert || ble.connections.state[tag.id] == .connected || ble.connections.state[tag.id] == .writting
        }
    }
    
    private let TAG_ROTATTION_CENTER = CGPoint(x: 0.5, y: 0.2)
    
    required init?(coder aDecoder: NSCoder) {
        store = TagStoreDefault.shared
        ble = BLEDefault.shared
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lc.d("viewWillAppear")
        let pos = view.superview?.tag
        if pos != nil {
            tag = store.tagBy(pos: pos!)
            if tag != nil {
                log.d("setupTag on viewWillAppear")
                setupTag()
                setupBottomButtons()
                setupState(id: tag!.id, fromState: ble.connections.state[tag!.id], toState: ble.connections.state[tag!.id])
            }
        }
        
        buttonLost.isHidden = true
        subscribe()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.lc.d("viewWillDisappear")
        unSubscribe()
        if tag != nil {
            if (ble.alert.isAlerting(id: tag!.id)) {
                DispatchQueue.global(qos: .background).async {
                    self.ble.alert.stopAlert(id: self.tag!.id, timeout: BLE_TIMEOUT)
                }
            }
        }
        self.stopTagAnimation()
        self.stopLostAnimation()
        super.viewWillDisappear(animated)
    }
    
    var layoutDone = false; //obsolete, has no means because of may layouts
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // need to call it after layout done because of anymation anchor
        lc.d("viewDidLayoutSubviews")
        if (!layoutDone) {
            layoutDone = true
            stopTagAnimation()
            setupTagAnimation()
        } else {
            setupAnchor()
        }
    }
    
    @IBAction
    func onAlert(_ sender: UIView) {
        guard let tag = tag else { return }
        self.store.set(alert: !alertState, forTag: tag)
    }
    
    @IBAction
    func onColor(_ sender: UIView) {
        guard let tag = tag else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Black".localized, style: .default) { _ in
            self.store.set(color: .black, forTag: tag)
        })
        alert.addAction(UIAlertAction(title: "Blue".localized, style: .default) { _ in
            self.store.set(color: .blue, forTag: tag)
        })
        alert.addAction(UIAlertAction(title: "Gold".localized, style: .default) { _ in
            self.store.set(color: .gold, forTag: tag)
        })
        alert.addAction(UIAlertAction(title: "Green".localized, style: .default) { _ in
            self.store.set(color: .green, forTag: tag)
        })
        alert.addAction(UIAlertAction(title: "Red".localized, style: .default) { _ in
            self.store.set(color: .red, forTag: tag)
        })
        alert.addAction(UIAlertAction(title: "White".localized, style: .default) { _ in
            self.store.set(color: .white, forTag: tag)
        })
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                  y: self.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    @IBAction
    func onEdit(_ sender: UIView) {
        guard let tag = tag else { return }
        
        let alert = UIAlertController(title: "iTag's name".localized, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = tag.name
        }
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { [weak alert] (_) in
            let name = alert?.textFields![0].text ?? ""
            self.store.set(name: name.trimmingCharacters(in: .whitespacesAndNewlines), forTag: tag)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (_) in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func onTag(_ sender: UIView) {
        if (sound.isPlaying) {
            sound.stop()
        }
        
        guard let tag = tag else { return }
        
        if ble.findMe.isFindMe(id: tag.id) {
            stopTagAnimation()
            ble.findMe.cancelFindMe(id: tag.id)
            return
        }
        
        if ble.alert.isAlerting(id: tag.id) {
            DispatchQueue.global(qos: .background).async {
                self.ble.alert.stopAlert(id: tag.id, timeout: BLE_TIMEOUT)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                self.ble.alert.startAlert(id: tag.id, timeout: BLE_TIMEOUT)
            }
        }
    }
    
    @IBAction func onForget(_ sender: UIView) {
        guard let tag = tag else { return }
        store.forget(id: tag.id)
    }
    
    @IBAction func onLastSeen(_ sender: UIView) {
        if sender.isHidden {
            return
        }
        guard let id = tag?.id else {return}
        guard let lastCoord = LastSeenLocation(id: id).coordinate else { return }
        
        let latitude:CLLocationDegrees =  lastCoord.latitude
        let longitude:CLLocationDegrees =  lastCoord.longitude

        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = tag?.name ?? "iTag"
        mapItem.openInMaps(launchOptions: options)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func setupTag() {
        guard let tag = tag else { return }
        var image: UIImage? = nil
        switch tag.color {
        case .black:
            image = BLETagViewController.imageBlack
        case .blue:
            image = BLETagViewController.imageBlue
        case .gold:
            image = BLETagViewController.imageGold
        case .green:
            image = BLETagViewController.imageGreen
        case .red:
            image = BLETagViewController.imageRed
        case .white:
            image = BLETagViewController.imageWhite
        }
        
        buttonTag?.setImage(image, for: .normal)
        buttonTag?.imageView?.contentMode = .scaleAspectFit
        
        labelName?.text = tag.name
    }
    
    private func setupBottomButtons() {
        buttonAlert?.setImage(alertState ? BLETagViewController.imageAlert : BLETagViewController.imageNoAlert, for: .normal)
    }
    
    private var pendingState: BLEConnectionState = .disconnected
    private var pendingStateUpdate = false
    private func setupState(id: String, fromState: BLEConnectionState, toState: BLEConnectionState) {
        
        if  tag == nil || tag!.id != id  { return }
        
        pendingState = toState
        if !pendingStateUpdate {
            pendingStateUpdate = true
            DispatchQueue.main.asyncAfter(deadline: 0.5.dispatchTime, execute: {
                var image: UIImage? = nil
                switch self.pendingState {
                case .disconnected:
                    image = BLETagViewController.imageDisabled
                case .connecting:
                    image = BLETagViewController.imageConnecting
                case .disconnecting:
                    image = BLETagViewController.imageScanning
                case .discovering:
                    image = BLETagViewController.imageSetup
                case .discoveringServices:
                    image = BLETagViewController.imageSetup
                case .discoveringCharacteristics:
                    image = BLETagViewController.imageSetup
                case .connected:
                    image = BLETagViewController.imageConnected
                case .writting:
                    image = BLETagViewController.imageScanning
                case .reading:
                    image = BLETagViewController.imageScanning
                }
                self.imageState?.image = image
                self.pendingStateUpdate = false
            })
        }
        
        setupTagAnimation()
        setupLostAnimation()
    }
    
    private func setupTagAnimation() {
        if !layoutDone {
            log.d("cancel setupTagAnimation before layout done")
            return
        }
        guard let id = tag?.id else {
            return
        }
        
        let state = ble.connections.state[id]
        let isAlerting = ble.alert.isAlerting(id: id)
        let findMe = ble.findMe.isFindMe(id: id)
        if  isAlerting || findMe  {
            log.d("will startTagAnimation alerting(calling)=\(isAlerting) || findMe=\(findMe)")
            startTagAnimation()
        } else {
            if tag?.alert == true && state != .connected {
                log.d("will startTagAnimation alert(linked)=\(tag?.alert ?? false) && state=\(state)")
                startTagAnimation()
            } else {
                log.d("will stopTagAnimation alerting(calling)=\(isAlerting) || findMe=\(findMe), alert(linked)=\(tag?.alert ?? false) && state=\(state) ")
                stopTagAnimation()
            }
        }
    }
    
    private func setupAnchor() {
        if !self.layoutDone {
            return
        }
        guard let view = self.buttonTag else { return }
        buttonTagContainer!.setNeedsLayout()
        buttonTagContainer!.layoutIfNeeded()
        view.layer.position = CGPoint(x: buttonTagContainer!.bounds.width/2, y: view.bounds.height * TAG_ROTATTION_CENTER.y)
        view.layer.anchorPoint = TAG_ROTATTION_CENTER
    }
    
    let transform0 = CGAffineTransform(rotationAngle: 0)
    let transform1 = CGAffineTransform(rotationAngle: -CGFloat.pi/12)
    let transform2 = CGAffineTransform(rotationAngle: CGFloat.pi/12)
    
    var tagAnimating = false
    var tagAimatingStopRequest = false
    
    private func stopTagAnimationInThread()
    {
        log.d("stopTagAnimation")
        if (!tagAnimating) {
            log.d("stopTagAnimation cancel because not animating")
            return
        }
        guard let view = self.buttonTag else { return }
        tagAnimating = false
        tagAimatingStopRequest = true
        
        setupAnchor()
        view.layer.removeAllAnimations()
        view.transform = .identity
        
        log.d("exit stopTagAnimation")
    }
    
    private func stopTagAnimation()
    {
        if Thread.isMainThread {
            stopTagAnimationInThread()
        } else {
            DispatchQueue.main.sync {
                stopTagAnimationInThread()
            }
        }
    }
    
    private func startTagAnimationInThread(complete: @escaping () -> Void) {
        log.d("startTagAnimation")
        if tagAnimating {
            log.d("startTagAnimation cancel because animating")
            return
        }
        if !layoutDone {
            log.d("startTagAnimation cancel because layout not done")
            return
        }
        tagAnimating = true
        tagAimatingStopRequest = false
        guard let view = self.buttonTag else { return }
        
        setupAnchor()
        UIView.animate(withDuration: 0, delay: 0, options: [.allowUserInteraction], animations: {
            view.transform = self.transform0
        },completion: { _ in
            self.log.d("tagAnimation0 completed")
            if self.tagAimatingStopRequest {
                self.log.d("tagAimatingStopRequest noted")
                return
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                view.transform = self.transform1
            }, completion: { _ in
                self.log.d("tagAnimation1 completed")
                if self.tagAimatingStopRequest {
                    self.log.d("tagAimatingStopRequest noted")
                    return
                }
                UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                    view.transform = self.transform2
                }, completion: {_ in
                    self.log.d("tagAnimation2 completed")
                    complete()
                })
            })
        })
        log.d("exit startTagAnimation")
    }
    
    private func startTagAnimation() {
        if Thread.isMainThread {
            startTagAnimationInThread(complete: {})
        } else {
            let lock = DispatchSemaphore(value: 0   )
            DispatchQueue.main.async {
                self.startTagAnimationInThread(complete: {lock.signal()})
            }
            log.d("lock startTagAnimation")
            lock.wait()
            log.d("unlock startTagAnimation")
        }
    }
    
    private func setupLostAnimation() {
        guard let id = tag?.id else {
            return
        }
        
        let state = ble.connections.state[id]
        log.d("setupLostAnimation alert(linked)=\(tag?.alert ?? false) state=\(state)")
        if tag?.alert == true && (state == .disconnected || state == .connecting) {
            startLostAnimation()
        } else {
            stopLostAnimation()
        }
    }
    
    
    var requestStopLastAnimation = false
    private func startLostAnimation() {
        requestStopLastAnimation = false
        // delay for 1 sec in order to skip connecting flash
        DispatchQueue.main.asyncAfter(deadline: 1.dispatchTime, execute: {
            if self.requestStopLastAnimation {
                return
            }
            guard let view = self.buttonLost else { return }
            UIView.transition(with: view, duration: 0.6, options: [.transitionCrossDissolve, .repeat, .autoreverse, .allowUserInteraction], animations: {view.isHidden = false}, completion: {_ in})
        })
    }
    
    private func stopLostAnimation() {
        requestStopLastAnimation = true
        DispatchQueue.main.async {
            guard let view = self.buttonLost else { return }
            view.layer.removeAllAnimations()
            view.isHidden = true
        }
    }
    
    private func subscribe() {
        if disposable != nil {
            return
        }
        let pos = view.superview?.tag
        disposable = DisposeBag()
        disposable!.add(store.observable.subscribe(on: DispatchQueue.main, id: "remember/forget view_\(pos ?? 99)", handler: {v in
            self.setupBottomButtons()
        }))
        disposable!.add(ble.connections.stateObservable.subscribe(on: DispatchQueue.main, id: "connect/disconnect view_\(pos ?? 99)", handler: {(id: String, fromState: BLEConnectionState, toState: BLEConnectionState) in
            if id != self.tag?.id {
                return
            }
            self.log.d("state change from \(fromState) to \(toState)")
            self.setupState(id: id, fromState: fromState, toState: toState)
            self.setupBottomButtons()
        }))
        disposable!.add(ble.findMe.findMeObservable.subscribe(on: DispatchQueue.main,id: "find me view_\(pos ?? 99)" , handler: { (id, findMe) in
            if id != self.tag?.id {
                return
            }
            self.stopTagAnimation()
            self.setupTagAnimation()
        }))
        disposable!.add(ble.alert.alertObservable.subscribe(on: DispatchQueue.main, id: "alert view_\(pos ?? 99)", handler: { status in
            if status.id != self.tag?.id {
                return
            }
            self.setupTagAnimation()
        }))
        disposable!.add(applicationStateObservable.subscribe(on: DispatchQueue.main, handler: {state in
            switch state {
            case .ACTIVE:
                self.lc.d("application becomes active")
                self.setupTagAnimation()
                self.setupLostAnimation()
                break
            case .INACTIVE:
                self.lc.d("application becomes inactive")
                self.stopTagAnimationInThread()
                self.stopLostAnimation()
                break
            }
        }))
        
    }
    
    private func unSubscribe() {
        if disposable == nil {
            return
        }
        disposable!.dispose()
        disposable = nil
    }
    
}
