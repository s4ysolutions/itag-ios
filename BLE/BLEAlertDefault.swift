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
    var alerts: Set<String> = []
    
    init(store: BLEConnectionsStoreInterface) {
        self.store = store
    }
    
    func startAlert(id: String, timeout: Int) {
        let connection = store.getOrMake(id: id)
        let error = connection.makeAvailabe(timeout: timeout)
        if error == nil {
            let writeError = connection.writeImmediateAlert(volume: .HIGH_ALERT)
            if writeError == nil {
                alerts.insert(id)
            } else {
                alerts.remove(id)
            }
        }
    }
    
    func stopAlert(id: String, timeout: Int) {
        let connection = store.getOrMake(id: id)
        let error = connection.makeAvailabe(timeout: timeout)
        if error == nil {
            _ = connection.writeImmediateAlert(volume: .NO_ALERT)
            alerts.remove(id)
        }
    }
    
    func toggleAlert(id: String, timeout: Int) {
        if alerts.contains(id) {
            stopAlert(id: id, timeout: timeout)
        } else {
            startAlert(id: id, timeout: timeout)
        }
    }
    
}
