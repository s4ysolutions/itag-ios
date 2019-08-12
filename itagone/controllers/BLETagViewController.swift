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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let pos = view.superview?.tag
        if pos != nil {
            tag = store.tagBy(pos: pos!)
            if tag != nil {
                setupTag()
                setupState()
            }
        }
        disposable?.dispose()
        disposable = DisposeBag()
        disposable!.add(store.observable.subscribe(on: DispatchQueue.main, id: "tag_change_\(pos ?? 99)", handler: {_ in
            self.setupTag()
        }))
        disposable!.add(ble.connections.stateObservable.subscribe(on: DispatchQueue.main, id: "state_\(pos ?? 99)", handler: {_ in
            self.setupState()
            self.setupTag()
        }))
        let button = buttonTag!
        // button.layer.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        
        //let dy: CGFloat = 0.3 * button.frame.height
        //button.layer.position.y = 100//-dy
        
        let anchorPoint = CGPoint(x: 0.5, y: 0.2)
        let rotationPoint = CGPoint(x: 0, //button.layer.frame.width * anchorPoint.x,
                                    y: -100) //50) //button.layer.frame.height * anchorPoint.y)
        //button.layer.anchorPoint = anchorPoint
        button.layer.position = rotationPoint
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposable?.dispose()
        super.viewWillDisappear(animated)
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
    
    let sound = SoundDefault()
    @IBAction func onTag(_ sender: UIView) {
        if (sound.isPlaying) {
            sound.stop()
            return
        }
        guard var tag = tag else { return }
        DispatchQueue.global(qos: .background).async{
            if tag.isAlerting {
                DispatchQueue.main.async{
                    self.stopAnimation()
                }
                self.ble.alert.stopAlert(id: tag.id, timeout: BLE_TIMEOUT)
                tag.isAlerting = false
            } else {
                DispatchQueue.main.async {
                    self.startAnimation()
                }
                self.ble.alert.startAlert(id: tag.id, timeout: BLE_TIMEOUT)
                tag.isAlerting = true
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
        
        buttonAlert?.setImage(alertState ? BLETagViewController.imageAlert : BLETagViewController.imageNoAlert, for: .normal)
        
        labelName?.text = tag.name
    }
    
    private func setupState() {
        guard let tag = tag else { return }
        let state = ble.connections.state[tag.id]
        
        var image: UIImage? = nil
        switch state {
        case .disconnected:
            image = BLETagViewController.imageDisabled
        case .connecting:
            image = BLETagViewController.imageConnecting
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
    }
    
    var y: CGFloat = 0
    private func stopAnimation() {
        guard let view = buttonTag else { return }
        view.layer.removeAllAnimations()
        if y != 0 {
            view.layer.position.y = y
            view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            view.transform = .identity
        }
        view.layoutIfNeeded()
    }
    
    let anchorY: CGFloat = 0.2
    let transform0 = CGAffineTransform(rotationAngle: 0)
    let transform1 = CGAffineTransform(rotationAngle: -CGFloat.pi/7)
    let transform2 = CGAffineTransform(rotationAngle: CGFloat.pi/7)

    private func startAnimation() {
        guard let view = buttonTag else { return }
        y = view.layer.position.y

        let oldY = view.bounds.size.height * view.layer.anchorPoint.y
        let newY = view.bounds.size.height * anchorY
        
        
        view.layer.position.y = view.layer.position.y - oldY + newY
        view.layer.anchorPoint = CGPoint(x: 0.5, y: anchorY)
        view.transform = transform1
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0, delay: 0, options: [.allowUserInteraction], animations: {
            view.transform = self.transform0
            self.view.layoutIfNeeded()
        },completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                view.transform = self.transform1
                self.view.layoutIfNeeded()
            }, completion: { _ in
                 UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                 view.transform = self.transform2
                 }, completion: nil)
            })
        })
    }
}
