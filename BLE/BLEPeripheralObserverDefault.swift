//
//  BLEPeripheralObserver.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

class BLEPeripheralObserverDefault: NSObject, BLEPeripheralObserverInterface {    
    let discoverServicesChannel = Channel<CBPeripheral>()
    var discoverServicesObservable: Observable<CBPeripheral> {
        get {
            return discoverServicesChannel.observable
        }
    }
    
    let discoverCharacteristicsChannel = Channel<(CBPeripheral, CBService, Error?)>()
    var discoverCharacteristicsObservable: Observable<(CBPeripheral, CBService, Error?)> {
        get {
            return discoverCharacteristicsChannel.observable
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        discoverServicesChannel.broadcast(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        discoverCharacteristicsChannel.broadcast((peripheral, service, error))
    }
}
