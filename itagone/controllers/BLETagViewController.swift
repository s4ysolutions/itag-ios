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
    
    static let imageBlack = UIImage(named: "tagBlack")
    static let imageBlue = UIImage(named: "tagBlue")
    static let imageGold = UIImage(named: "tagGold")
    static let imageGreen = UIImage(named: "tagGreen")
    static let imageRed = UIImage(named: "tagRed")
    static let imageWhite = UIImage(named: "tagWhite")

    static let imageAlert = UIImage(named: "btnAlert")
    static let imageNoAlert = UIImage(named: "btnNoAlert")

    let store: TagStoreInterface
    
    var disposable: DisposeBag?
    var tag: TagInterface?
    let ble: BLEInterface
    
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
            }
        }
        disposable?.dispose()
        disposable = DisposeBag()
        disposable!.add(store.observable.subscribe(on: DispatchQueue.main, id: "tag_change_\(pos ?? 99)", handler: {_ in
            self.setupTag()
        }))
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposable?.dispose()
        super.viewWillDisappear(animated)
    }
    
    @IBAction
    func onAlert(_ sender: UIView) {
        guard let tag = tag else { return }
        self.store.set(alert: !tag.alert, forTag: tag)
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
        guard let tag = tag else { return }
        ble.alert.toggleAlert(id: tag.id, timeout: BLE_TIMEOUT)
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
        
        buttonAlert?.setImage(tag.alert ? BLETagViewController.imageAlert : BLETagViewController.imageNoAlert, for: .normal)
        
        labelName?.text = tag.name
    }
}
