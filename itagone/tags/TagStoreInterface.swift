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
}

protocol TagStoreInterface {
    var count: Int { get }
    var observable: Observable<StoreOp> { get }
    subscript(id: String) -> TagInterface? {get}
    func forget(id: String)
    func remember(tag: TagInterface)
    func remembered(id: String) -> Bool
}
