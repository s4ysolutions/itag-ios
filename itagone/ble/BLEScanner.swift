//
//  BLEScanner.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import CoreBluetooth
import Rasat

class BLEScanner {
    var timeoutSubject = Subject(0)
    var timer: Timer? = nil
    let manager: CBCentralManager
    
    init (_ manager: CBCentralManager) {
        self.manager = manager
    }
    
    func start(manager: CBCentralManager, timeout: Int) {
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
}
