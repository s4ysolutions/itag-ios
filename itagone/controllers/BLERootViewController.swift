//
//  ViewController.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import UIKit
import Rasat

class BLERootViewController: UIViewController {
    @IBOutlet weak var containerView: UIView?

    let ble: BLE
    let store: TagStoreInterface
    var contentID = ""

    required init?(coder aDecoder: NSCoder) {
        ble = BLEDefault.shared
        store = TagStoreDefault.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupContent()
    }

    // MARK: - Manage Content
    
    func setupContent() {
        print("count", store.count)
        contentID = store.count == 0 ? "tags0" : store.count == 1 ? "tag1" : store.count == 2 ? "tags2" : store.count == 3 ? "tags3" : "tags4"
        print(contentID)
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

