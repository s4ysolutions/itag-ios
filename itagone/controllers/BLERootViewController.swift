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

    var ble: BLE?
    var contentID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        ble = BLEDefault.shared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupContent()
    }

    // MARK: - Manage Content
    
    func setupContent() {
        contentID = (ble?.isScanning ?? false ) ? "tags0" : "tags0"
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

