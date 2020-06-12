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

class BLERootViewController: UIViewController {
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var soundButton: UIButton?
    
    static let imageNoSound = UIImage(named: "itemNoSound")
    static let imageSound = UIImage(named: "itemSound")
    static let imageVibration = UIImage(named: "itemVibration")
    
    let ble: BLEInterface
    let store: TagStoreInterface
    
    var contentID = ""
    var disposable: DisposeBag?
    
    required init?(coder aDecoder: NSCoder) {
        ble = BLEDefault.shared
        store = TagStoreDefault.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupItemSound()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        disposable?.dispose()
        disposable = DisposeBag()
        disposable!.add(store.observable.subscribe(on: DispatchQueue.main, id: "tag_change_root", handler: {_ in
            self.setupContent()
        }))
        setupContent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposable?.dispose()
        super.viewWillDisappear(animated)
    }
    
    @IBAction
    func sound(_ sender: UIView) {
        let mode = getAlertSoundMode()
        switch mode {
        case .NoSound:
            setAlertSoundMode(mode: .Sound)
        case .Sound:
            setAlertSoundMode(mode: .Vibration)
        case .Vibration:
            setAlertSoundMode(mode: .NoSound)
        }
        setupItemSound()
    }
    
    private func setupItemSound() {
        let mode = getAlertSoundMode()
        
        let image = { () -> UIImage? in
            switch mode {
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
    
    // MARK: - Manage Content
    
    func setupContent() {
        contentID = store.count == 0 ? "tags0" : store.count == 1 ? "tag1" : store.count == 2 ? "tags2" : store.count == 3 ? "tags3" : "tags4"
        guard let contentViewController = self.storyboard?.instantiateViewController(withIdentifier: contentID) else { return }
        guard let contentView = contentViewController.view else { return }
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

