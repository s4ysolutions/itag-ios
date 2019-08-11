//
//  TagStoreInterface.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

enum StoreOp {
    case remember
    case forget
    case change
}

protocol TagStoreInterface {
    var count: Int { get }
    var observable: Observable<StoreOp> { get }
    func by(id: String) -> TagInterface?
    func tagBy(pos: Int) -> TagInterface?
    func forget(id: String)
    func remember(tag: TagInterface)
    func remembered(id: String) -> Bool
    func set(alert: Bool, forTag: TagInterface)
    func set(color: TagColor, forTag: TagInterface)
    func set(name: String, forTag: TagInterface)
    func connectAll()
}
