//
//  BLEStoreDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEConnectionsStoreDefault: BLEConnectionsStoreInterface {
    var store: [String: BLEConnectionInterface] = [:]
    
    subscript(id: String) -> BLEConnectionInterface? {
        get {
            return store[id]
        }
    }
    
    func append(connection: BLEConnectionInterface) {
      //  store[connection.peripheral.identifier.uuidString] = connection
    }
    
}
