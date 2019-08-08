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

class BLEDefault: BLE {
    static let shared = BLEDefault()
    /*
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
    */
    
    let manager: CBCentralManager
    let delegate: BLEDefaultDelegate
    let scanner: BLEScanner

    init() {
        delegate = BLEDefaultDelegate()
        manager = CBCentralManager(delegate: delegate, queue: DispatchQueue.global(qos: .background))
        scanner = BLEScanner(manager)
    }

    var state: CBManagerState {
        get {
            return manager.state
        }
    }
    
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
    
    var scannerObservable: Observable<CBPeripheral> {
        get {
            return delegate.scannerChannel.observable
        }
    }
    
    func startScan(timeout: Int) {
        scanner.start(manager: manager, timeout: timeout)
    }
    
    func stopScan() {
        scanner.stop()
    }


}
