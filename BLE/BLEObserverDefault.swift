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

class BLEObserverDefault: NSObject, BLEObserverInterface, CBCentralManagerDelegate {
    
    let scanPeripheralsChannel = Channel<CBPeripheral>()

    var delegate: CBCentralManagerDelegate {
        get {
            return self
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
        scanPeripheralsChannel.broadcast(peripheral)
    }

    
    var scanObservable: Observable<CBPeripheral> {
        get {
            return scanPeripheralsChannel.observable
        }
    }
}
