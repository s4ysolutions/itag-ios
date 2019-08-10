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

class BLEManagerObserverDefault: NSObject, BLEManagerObserverInterface {
    let discoverPeripheralChannel = Channel<(CBPeripheral, [String: Any], NSNumber)>()
    var discoverObservable: Observable<(CBPeripheral, [String: Any], NSNumber)> {
        get {
            return discoverPeripheralChannel.observable
        }
    }

    let connectPeripheralsChannel = Channel<CBPeripheral>()
    var connectObservable: Observable<CBPeripheral> {
        get {
            return connectPeripheralsChannel.observable
        }
    }
    
    let connectPeripheralsErrorChannel = Channel<(CBPeripheral,Error?)>()
    var connectErrorObservable: Observable<(CBPeripheral,Error?)> {
        get {
            return connectPeripheralsErrorChannel.observable
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
        discoverPeripheralChannel.broadcast((peripheral, advertisementData, RSSI))
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        connectPeripheralsChannel.broadcast(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager,
                                 didFailToConnect peripheral: CBPeripheral,
                                 error: Error?) {
        connectPeripheralsErrorChannel.broadcast((peripheral, error))
    }

}
