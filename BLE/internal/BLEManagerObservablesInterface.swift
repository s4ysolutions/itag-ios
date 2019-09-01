//
//  BLEObserverInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

protocol BLEManagerObservablesInterface: CBCentralManagerDelegate {
    var didConnectPeripheral: Observable<CBPeripheral> { get }
    var didFailToConnectPeripheral: Observable<(peripheral: CBPeripheral,error: Error?)> { get }
    var didDisconnectPeripheral: Observable<(peripheral: CBPeripheral,error: Error?)> { get }
    var didDiscoverPeripheral: Observable<(peripheral: CBPeripheral, data: [String: Any], rssi: NSNumber)> { get }
    var didUpdateState: Observable<CBManagerState> { get }
    var willRestoreState: Observable<[CBPeripheral]> { get }
}
