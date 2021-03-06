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

class BLEPeripheralObservablesDefault: NSObject, BLEPeripheralObservablesInterface {    
    let didDiscoverServicesChannel = Channel<CBPeripheral>()
    var didDiscoverServices: Observable<CBPeripheral> {
        get {
            return didDiscoverServicesChannel.observable
        }
    }
    
    let didDiscoverCharacteristicsForServiceChannel = Channel<(peripheral: CBPeripheral, service: CBService, error: Error?)>()
    var didDiscoverCharacteristicsForService: Observable<(peripheral: CBPeripheral, service: CBService, error: Error?)> {
        get {
            return didDiscoverCharacteristicsForServiceChannel.observable
        }
    }
    
    let didUpdateNotificationStateForCharacteristicChannel = Channel<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)>()
    var didUpdateNotificationStateForCharacteristic: Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)> { get {
        return didUpdateNotificationStateForCharacteristicChannel.observable
        } }
    
    
    let didUpdateValueForCharacteristicChannel = Channel<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)>()
    var didUpdateValueForCharacteristic: Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)> {
        get {
            return didUpdateValueForCharacteristicChannel.observable
        }
    }
    
    let didWriteValueForCharacteristicChannel = Channel<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)>()
    var didWriteValueForCharacteristic: Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)> {
        get {
            return didWriteValueForCharacteristicChannel.observable
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        didDiscoverServicesChannel.broadcast(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        didDiscoverCharacteristicsForServiceChannel.broadcast((peripheral: peripheral, service: service, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        didWriteValueForCharacteristicChannel.broadcast((peripheral: peripheral, characteristic: characteristic, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        didUpdateNotificationStateForCharacteristicChannel.broadcast((peripheral: peripheral, characteristic: characteristic, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        didUpdateValueForCharacteristicChannel.broadcast((peripheral: peripheral, characteristic: characteristic, error: error))
    }
}
