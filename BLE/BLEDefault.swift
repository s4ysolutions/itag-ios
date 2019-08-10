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



public class BLEDefault: BLEInterface {
    public static let shared = BLEDefault(
        observer: BLEObserverDefault(),
        scannerFactory: BLEScannerFactoryDefault(),
        store: BLEConnectionsStoreDefault())
    
    public let scanner: BLEScannerInterface
    
    private let manager: CBCentralManager
    private let observer: BLEObserverInterface
    private let store: BLEConnectionsStoreInterface

    init(observer: BLEObserverInterface,
         scannerFactory: BLEScannerFactoryInterface,
         store: BLEConnectionsStoreInterface) {
        
        self.store = store
        self.observer = observer
        
        manager = CBCentralManager(delegate: observer.delegate, queue: DispatchQueue.global(qos: .background))
        scanner = scannerFactory.scanner(manager: manager, observer: observer)
    }

    var state: CBManagerState {
        get {
            return manager.state
        }
    }
    /*
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

    func startCallTag(id: String) {
        DispatchQueue.global(qos: .background).async {
            let item = self.store[id]
            if item == nil {
                
            }
        }
    }
 */
}
