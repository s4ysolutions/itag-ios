//
//  BLEDelegate.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

class BLEManagerObservablesDefault: NSObject, BLEManagerObservablesInterface {
    let didConnectPeripheralChannel = Channel<CBPeripheral>()
    var didConnectPeripheral: Observable<CBPeripheral> {
        get {
            return didConnectPeripheralChannel.observable
        }
    }
    
    let didFailToConnectPeripheralChannel = Channel<(peripheral: CBPeripheral, error: Error?)>()
    var didFailToConnectPeripheral: Observable<(peripheral: CBPeripheral, error: Error?)> {
        get {
            return didFailToConnectPeripheralChannel.observable
        }
    }
    
    let didDiscoverPeripheralChannel = Channel<(peripheral: CBPeripheral, data: [String: Any], rssi: NSNumber)>()
    var didDiscoverPeripheral: Observable<(peripheral: CBPeripheral, data: [String: Any], rssi: NSNumber)> {
        get {
            return didDiscoverPeripheralChannel.observable
        }
    }
    
    let didUpdateStateChannel = Channel<CBManagerState>()
    var didUpdateState: Observable<CBManagerState> {
        get {
            return didUpdateStateChannel.observable
        }
    }
    
    let didDisconnectPeripheralChannel = Channel<(peripheral: CBPeripheral, error: Error?)>()
    var didDisconnectPeripheral: Observable<(peripheral: CBPeripheral, error: Error?)> {
        get {
            return didDisconnectPeripheralChannel.observable
        }
    }
    
    let willRestoreStateChannel = Channel<[CBPeripheral]>()
    var willRestoreState: Observable<[CBPeripheral]> {
        get {
            return willRestoreStateChannel.observable
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        guard let peripheralsAny = dict[CBCentralManagerRestoredStatePeripheralsKey]
            else { return }
        guard let peripherals = peripheralsAny as? [CBPeripheral] else { return }
        if peripherals.count == 0 { return }
        willRestoreStateChannel.broadcast(peripherals)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateStateChannel.broadcast(central.state)
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        @unknown default:
            print("central.state is .@unkonw")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        didDiscoverPeripheralChannel.broadcast((peripheral, advertisementData, RSSI))
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        didConnectPeripheralChannel.broadcast(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager,
                                 didFailToConnect peripheral: CBPeripheral,
                                 error: Error?) {
        didFailToConnectPeripheralChannel.broadcast((peripheral, error))
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        didDisconnectPeripheralChannel.broadcast((peripheral, error))
    }
}
