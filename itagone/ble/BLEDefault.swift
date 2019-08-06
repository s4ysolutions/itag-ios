//
//  DefaultBLE.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import CoreBluetooth
import Rasat

class BLEDefault: NSObject, CBCentralManagerDelegate, BLE {
    
    static var _shared: BLEDefault?
    static var shared: BLEDefault {
        get{
            if _shared == nil {
               _shared = BLEDefault()
            }
            return _shared!
        }
    }
    
    private var _manager: CBCentralManager?
    private var manager: CBCentralManager {
        get {
            if _manager == nil {
                _manager = CBCentralManager(
                    delegate: self,
                    queue: DispatchQueue.global(qos: .background))
            }
            return _manager!
        }
    }
    
    var state: CBManagerState {
        get {
            return _manager?.state ?? .unknown
        }
    }
    
    internal let scanner = BLEScanner()
    
    var isScanning: Bool {
        get {
            return scanner.isScanning
        }
    }
    
    var scanningTimeout: Int {
        get {
            return scanner.scanningTimeout
        }
    }

    var scannerTimerObservable: Observable<Int> {
        get{
            return scanner.timeoutSubject.observable
        }
    }
    
    internal var scannerChannel = Channel<CBPeripheral>()
    var scannerObservable: Observable<CBPeripheral> {
        get {
            return scannerChannel.observable
        }
    }
    
    func startScan(timeout: Int) {
        print(manager.delegate)
        scanner.start(manager: manager, timeout: timeout)
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
        scannerChannel.broadcast(peripheral)
    }
}
