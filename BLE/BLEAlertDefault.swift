//
//  BLEAlertDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEAlertDefault: BLEAlertInterface {
    let store: BLEConnectionsStoreInterface
    
    init(store: BLEConnectionsStoreInterface) {
        self.store = store
    }
    
    func startAlert(id: String, timeout: Int) {
        let connection = store.getOrMake(id: id)
        let error = connection.makeAvailabe(timeout: timeout)
        if error == nil {
            connection.writeImmediateAlert(volume: .HIGH_ALERT)
        }
    }
    
    func stopAlert(id: String) {
        let connection = store.getOrMake(id: id)
        let error = connection.makeAvailabe(timeout: 5)
        if error == nil {
            connection.writeImmediateAlert(volume: .NO_ALERT)
        }
    }
    
    
}
