//
//  BLEAlertDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

enum AlertVolume: UInt8 {
    case NO_ALERT = 0x00
    case MEDIUM_ALERT = 0x01
    case HIGH_ALERT = 0x02
    var data: Data {
        get {
            var value = self.rawValue
            return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        }
    }
}

extension Data {
    var alertVolume: AlertVolume {
        get {
            var rawValue: UInt8 = 0
            self.copyBytes(to:&rawValue, count: MemoryLayout<UInt8>.size)
            return AlertVolume(rawValue: rawValue)!
        }
    }
}


class BLEAlertDefault: BLEAlertInterface {
    let store: BLEConnectionsStoreInterface
    var alerts: Set<String> = []
    let disposables = DisposeBag()

    init(store: BLEConnectionsStoreInterface) {
        self.store = store
    }
    
    func isAlerting(id: String) ->  Bool {
       return alerts.contains(id)
    }
    
    func startAlert(id: String, timeout: Int) {
        let connection = store.getOrMake(id: id)
        let error = connection.makeAvailabe(timeout: timeout)
        if error == nil {
            let writeError = connection.writeImmediateAlert(volume: .HIGH_ALERT, timeout: timeout)
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
