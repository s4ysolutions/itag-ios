//
//  BLEAlertDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

// TODO: can not alert to few itags simultaneously

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
    var startingAlert = false
    var connecting = false
    let disposables = DisposeBag()

    public var alertObservable: Observable<(id: String, alert: Bool)> { get {
        return alertChannel.observable
        }
    }
    let alertChannel = Channel<(id: String, alert: Bool)>()
    
    init(store: BLEConnectionsStoreInterface) {
        self.store = store
    }
    
    func isAlerting(id: String) ->  Bool {
        let connection = store.get(id: id)
        return alerts.contains(id) && (connecting || (connection != nil && connection!.isConnected))
    }
    
    func startAlert(id: String, timeout: Int) {
        if (!startingAlert) {
            alerts.insert(id)
            alertChannel.broadcast((id: id, alert: true))
            // avoid re-enter
            startingAlert = true
            connecting = true
            let connection = store.getOrMake(id: id)
            let error = connection.makeAvailabe(timeout: timeout)
            connecting = false
            // can be canceled by stopAlert
            if error == nil && isAlerting(id: id){
                let writeError = connection.writeImmediateAlert(volume: .HIGH_ALERT, timeout: timeout)
                if writeError != nil {
                    alerts.remove(id)
                    alertChannel.broadcast((id: id, alert: false))
                }
            } else {
                alerts.remove(id)
                alertChannel.broadcast((id: id, alert: false))
            }
            startingAlert = false
        }
    }
    
    func stopAlert(id: String, timeout: Int) {
        if (!startingAlert) {
            startingAlert = true
            connecting = true
            let connection = store.getOrMake(id: id)
            let error = connection.makeAvailabe(timeout: timeout)
            connecting = false
            startingAlert = false
            if error == nil {
                _ = connection.writeImmediateAlert(volume: .NO_ALERT)
            }
        }
        alerts.remove(id)
        alertChannel.broadcast((id: id, alert: false))
    }
    
    func toggleAlert(id: String, timeout: Int) {
        if alerts.contains(id) {
            stopAlert(id: id, timeout: timeout)
        } else {
            startAlert(id: id, timeout: timeout)
        }
    }
    
}
