//
//  BLEPeripheralObserverInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

protocol BLEPeripheralObserverInterface: CBPeripheralDelegate {
    var didDiscoverServices: Observable<CBPeripheral> { get }
    var didDiscoverCharacteristicsForService: Observable<(peripheral: CBPeripheral, service: CBService, error: Error?)> { get }
    var didWriteValueForCharacteristic: Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)> { get }
}
