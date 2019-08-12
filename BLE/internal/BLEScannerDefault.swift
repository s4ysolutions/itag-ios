//
//  BLEScannerDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

class BLEScannerDefault: BLEScannerInterface {
    
    let connections: BLEConnectionsInterface
    let manager: CBCentralManager
    let observables: BLEManagerObservablesInterface
    
    var timer: Timer? = nil
    var timeoutSubject = Subject(0)
    
    init (connections: BLEConnectionsInterface, manager: CBCentralManager) {
        self.connections = connections
        self.manager = manager
        self.observables = manager.delegate as! BLEManagerObservablesInterface
    }
    
    func start(timeout: Int, forceCancelIds: [String]) {
        if timer != nil {
            stop()
        }
        
        if manager.state != .poweredOn {
            return
        }
        
        for id in  forceCancelIds {
            connections.disconnect(id: id)
        }
        
        manager.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true, CBCentralManagerScanOptionSolicitedServiceUUIDsKey: []])
        
        timeoutSubject.value = timeout
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.timeoutSubject.value = self.timeoutSubject.value-1
            if self.timeoutSubject.value <= 0 {
                self.stop()
            }
        })
    }
    
    func stop() {
        manager.stopScan()
        timer?.invalidate()
        timer = nil
        timeoutSubject.value = 0
    }
    
    var isScanning: Bool {
        get {
            return timer != nil
        }
    }
    
    var scanningTimeout: Int {
        get {
            return timeoutSubject.value
        }
    }
    
    var timerObservable: Observable<Int> {
        get{
            return timeoutSubject.observable
        }
    }
    
    var peripheralsObservable: Observable<(peripheral: CBPeripheral, data: [String: Any], rssi: NSNumber)> {
        get {
            return observables.didDiscoverPeripheral
        }
    }
}
