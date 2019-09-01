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

class BLETagViewController: UIViewController {
    @IBOutlet weak var buttonAlert: UIButton?
    @IBOutlet weak var buttonTag: UIButton?
    @IBOutlet weak var labelName: UILabel?
    @IBOutlet weak var imageState: UIImageView?
    
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

    var disposable: DisposeBag?
    var tag: TagInterface?
    
    var alertState: Bool {
        get {
            guard let tag = tag else { return false}
            return tag.alert || ble.connections.state[tag.id] == .connected
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        store = TagStoreDefault.shared
        ble = BLEDefault.shared
        super.init(coder: aDecoder)
    }
 
    override func viewWillAppear(_ animated: Bool) {
        print("will Appear")
        let pos = view.superview?.tag
        if pos != nil {
            tag = store.tagBy(pos: pos!)
            if tag != nil {
                setupTag()
                setupBottomButtons()
                setupState(id: tag!.id, fromState: ble.connections.state[tag!.id], toState: ble.connections.state[tag!.id])
                if ble.findMe.isFindMe(id: tag!.id) {
                    self.startAnimation()
                } else {
                    self.stopAnimation()
                }
            }
        }
        
        disposable?.dispose()
        disposable = DisposeBag()
        disposable!.add(store.observable.subscribe(on: DispatchQueue.main, id: "remember/forget view_\(pos ?? 99)", handler: {_ in
            self.setupBottomButtons()
        }))
        disposable!.add(ble.connections.stateObservable.subscribe(on: DispatchQueue.main, id: "connect/disconnect view_\(pos ?? 99)", handler: {(id: String, fromState: BLEConnectionState, toState: BLEConnectionState) in
            print("will setup State", id, fromState,toState)
            self.setupState(id: id, fromState: fromState, toState: toState)
            self.setupBottomButtons()
          //  self.setupTag()
        }))
        disposable!.add(ble.findMe.findMeObservable.subscribe(on: DispatchQueue.main,id: "find me view_\(pos ?? 99)" , handler: { (id, findMe) in
            guard let tag = self.tag else { return }
            if tag.id != id { return }
            if findMe {
                self.startAnimation()
            } else {
                self.stopAnimation()
            }
        }))
        disposable!.add(applicationStateObservable.subscribe(on: DispatchQueue.main, handler: {state in
            switch state {
            case .ACTIVE:
                print("app active")
                if (self.isAnimating) {
                    self.startAnimation()
                }
                break
            case .INACTIVE:
                print("app inactive")
                self.stopAnimation()
                break
            }
        }))
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("will Disappear")
        disposable?.dispose()
        if tag != nil {
            DispatchQueue.global(qos: .background).async {
                self.ble.alert.stopAlert(id: self.tag!.id, timeout: BLE_TIMEOUT)
            }
            tag!.isAlerting = false
        }
        self.stopAnimation()
        super.viewWillDisappear(animated)
    }
    
    var isAnimatingDuringTransition = false
    override func viewWillLayoutSubviews() {
        isAnimatingDuringTransition = isAnimating
        self.stopAnimation()
        super.viewWillLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews", viewDidLayoutSubviews)
        super.viewDidLayoutSubviews()
        if isAnimatingDuringTransition {
            self.startAnimation()
            isAnimatingDuringTransition = false // precaution
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
        stopAnimation()
        
        guard var tag = tag else { return }
        
        if ble.findMe.isFindMe(id: tag.id) {
            ble.findMe.cancelFindMe(id: tag.id)
        } else {
            if ble.connections.state[tag.id] == .connected {
                if tag.isAlerting {
                    DispatchQueue.global(qos: .background).async {
                        self.ble.alert.stopAlert(id: tag.id, timeout: BLE_TIMEOUT)
                    }
                    tag.isAlerting = false
                } else {
                    DispatchQueue.global(qos: .background).async {
                        self.ble.alert.startAlert(id: tag.id, timeout: BLE_TIMEOUT)
                    }
                    tag.isAlerting = true
                    self.startAnimation()
                }
            } else {
                ble.connections.connect(id: tag.id)
            }
        }
    }
    
    @IBAction func onForget(_ sender: UIView) {
        guard let tag = tag else { return }
        store.forget(id: tag.id)
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
        print("setupTag", isAnimatingDuringTransition, isAnimating)
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
    
    private func setupState(id: String, fromState: BLEConnectionState, toState: BLEConnectionState) {
       
        if  tag == nil || tag!.id != id  { return }
        
        print("setupState", id, tag!.alert, fromState, toState, isAnimatingDuringTransition, isAnimating)
        
        var image: UIImage? = nil
        switch toState {
        case .unknown:
            image = BLETagViewController.imageDisabled
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
        
        imageState?.image = image
        
        if toState == .disconnected && tag!.alert && !isAnimating {
            self.startAnimation()
        } else {
            if toState == .connected && !tag!.isAlerting {
                self.stopAnimation()
            }
        }
    }
    
    var isAnimating = false
    
    var y: CGFloat = 0
    private func stopAnimation()
    {
        print("stopAnimation", isAnimatingDuringTransition, isAnimating)
        isAnimating = false
        guard let view = buttonTag else { return }
        view.layer.removeAllAnimations()
        if y != 0 {
            view.layer.position.y = y
            y = 0
        }
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.transform = .identity
    }
    
    let anchorY: CGFloat = 0.2
    let transform0 = CGAffineTransform(rotationAngle: 0)
    let transform1 = CGAffineTransform(rotationAngle: -CGFloat.pi/12)
    let transform2 = CGAffineTransform(rotationAngle: CGFloat.pi/12)
    
    private func startAnimation() {
        print("startAnimation async", isAnimatingDuringTransition, isAnimating)
        DispatchQueue.main.async {
            self.stopAnimation()
            self.isAnimating = true
            print("startAnimation sync", self.isAnimatingDuringTransition, self.isAnimating)
            guard let view = self.buttonTag else { return }
            
            let oldY = view.bounds.size.height * view.layer.anchorPoint.y
            let newY = view.bounds.size.height * self.anchorY
            
            self.y = view.layer.position.y
            view.layer.position.y = self.y - oldY + newY
            view.layer.anchorPoint = CGPoint(x: 0.5, y: self.anchorY)
            
            UIView.animate(withDuration: 0, delay: 0, options: [.allowUserInteraction], animations: {
                view.transform = self.transform0
            },completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    view.transform = self.transform1
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                        view.transform = self.transform2
                    }, completion: nil)
                })
            })
        }
        
    }
}
