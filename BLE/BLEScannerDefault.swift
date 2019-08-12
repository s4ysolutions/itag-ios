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
    
    var timeoutSubject = Subject(0)
    var timer: Timer? = nil
    let manager: CBCentralManager
    let observables: BLEManagerObservablesInterface
    
    init (manager: CBCentralManager) {
        self.manager = manager
        self.observables = manager.delegate as! BLEManagerObservablesInterface
    }
    
    func start(timeout: Int) {
        if timer != nil {
            stop()
        }
        
        if manager.state != .poweredOn {
            return
        }
        
        manager.scanForPeripherals(withServices: nil)
        
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
