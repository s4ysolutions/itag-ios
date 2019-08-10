//
//  BLEConnnectionDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

let IMMEDIATE_ALERT_SERVICE = CBUUID(string: "00001802-0000-1000-8000-00805f9b34fb")
let ALERT_LEVEL_CHARACTERISTIC = CBUUID(string: "00002a06-0000-1000-8000-00805f9b34fb")

class PeripheralDelegate: NSObject, CBPeripheralDelegate {
    
}

class BLEConnectionDefault: BLEConnectionInterface {
    let id: String
    let manager: CBCentralManager
    let managerObserver: BLEManagerObserverInterface
    let peripheralObserver: BLEPeripheralObserverInterface
    
    var peripheral: CBPeripheral?
    
    var characteristicImmediateAlert: CBCharacteristic?
    var serviceImmediateAlert: CBService?
    
    init(manager: CBCentralManager, peripheralObserverFactory: BLEPeripheralObserverFactoryInterface, id: String) {
        self.id = id
        self.manager = manager
        self.peripheralObserver = peripheralObserverFactory.observer()
        // NOTE: manager.delegate must be BLEManagerObserverInterface
        self.managerObserver = manager.delegate as! BLEManagerObserverInterface
    }
    
    var isConnected: Bool {
        get{
            return peripheral != nil && peripheral?.state == .connected
        }
    }
    private func waitForConnect(timeout: DispatchTime) -> BLEConnectError? {
        guard let peripheral = peripheral else {return .noPeripheral}
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let disposable = DisposeBag()
        var errorConnect: Error? = nil
        
        
        disposable.add(managerObserver.connectObservable.subscribe(handler: { connected in
            if connected.identifier == peripheral.identifier {
                print("connect ok")
                semaphore.signal()
            }
        }))
        disposable.add(managerObserver.connectErrorObservable.subscribe(handler: { (failed, error) in
            if failed.identifier == peripheral.identifier {
                print("connect error", error)
                errorConnect = error
                semaphore.signal()
                self.manager.cancelPeripheralConnection(failed)
            } else {
                print("strange connect error", failed, error)
            }
        }))
        defer {
            print("connect dispose")
            disposable.dispose()
        }
        print("connect start")
        manager.connect(peripheral, options: [:])
        if semaphore.wait(timeout: timeout) == .timedOut {
            print("connect timeout")
            self.manager.cancelPeripheralConnection(peripheral)
            return .timeout
        }
        
        print("connect exit", errorConnect)
        if errorConnect != nil { return .other(errorConnect!)}
        return nil
    }
    
    private func waitForDiscover(timeout: DispatchTime) -> BLEConnectError? {
        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        disposable.add(managerObserver.discoverObservable.subscribe(handler: {(discovered, data, rssi) in
            if discovered.identifier.uuidString == self.id {
                print("discover ok")
                self.peripheral = discovered
                semaphore.signal()
            }
        }))
        defer {
            print("discover dispose")
            disposable.dispose()
        }
        print("discover start")
        manager.scanForPeripherals(withServices: nil)
        if semaphore.wait(timeout: timeout) == .timedOut {
            print("discover timeout")
            return .timeout
        }
        print("discover exit")
        return nil
    }
    
    private func waitForDiscoverServices(timeout: DispatchTime) -> BLEConnectError?  {
        guard let peripheral = peripheral else { return .noPeripheral}
        
        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        let observer = peripheral.delegate as! BLEPeripheralObserverInterface
        disposable.add(observer.discoverServicesObservable.subscribe(handler: {discovered in
            if discovered.identifier == peripheral.identifier {
                semaphore.signal()
            }
        }))
        defer {
            disposable.dispose()
        }
        
        peripheral.discoverServices([IMMEDIATE_ALERT_SERVICE])
        if semaphore.wait(timeout: timeout) == .timedOut {
            return .timeout
        }
        return nil
    }
    
    
    private func waitForDiscoverCharacteristics(forService: CBService, timeout: DispatchTime) -> BLEConnectError?  {
        guard let peripheral = peripheral else { return .noPeripheral}
        
        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        var discoverError: Error? = nil
        
        let observer = peripheral.delegate as! BLEPeripheralObserverInterface
        disposable.add(observer.discoverCharacteristicsObservable.subscribe(handler: {(discovered, service, error) in
            discoverError = error
            if discovered.identifier == peripheral.identifier && service.uuid == forService.uuid {
                semaphore.signal()
            }
        }))
        defer {
            disposable.dispose()
        }
        
        peripheral.discoverCharacteristics([], for: forService)
        if semaphore.wait(timeout: timeout) == .timedOut {
            return .timeout
        }
        return nil
    }
    
    func makeAvailabe(timeout: Int) -> BLEConnectError? {
        print("peripheral make available")

        if peripheral == nil {
            guard let uuid = UUID(uuidString: id) else { return .badUUID }
            let known = manager.retrievePeripherals(withIdentifiers: [uuid])
            if known.count > 0 {
                peripheral = known[0]
                print("peripheral known", peripheral)
                if waitForConnect(timeout: timeout.dispatchTime) != nil {
                    peripheral = nil
                }
            } else {
                peripheral = manager.retrieveConnectedPeripherals(withServices: []).first(where: {connected in connected.identifier == uuid})
                print("peripheral connected", peripheral)
                if peripheral != nil {
                    if waitForConnect(timeout: timeout.dispatchTime) != nil {
                        peripheral = nil
                    }
                }
            }
        }

        let maxTimeout = timeout.dispatchTime
        if peripheral == nil {
            characteristicImmediateAlert = nil
            serviceImmediateAlert = nil
            let scanError = waitForDiscover(timeout: maxTimeout)
            print("peripheral descover", scanError)
            if scanError != nil { return .other(scanError!)}
            let connectError = waitForConnect(timeout: maxTimeout)
            if connectError != nil { return .other(connectError!)}

        }
        
        guard let peripheral = peripheral else {return .noPeripheral}
        if peripheral.delegate == nil {
            peripheral.delegate = peripheralObserver
        }

        if characteristicImmediateAlert == nil {
            if serviceImmediateAlert == nil {
                let discoverServiceError = waitForDiscoverServices(timeout: maxTimeout)
                print("peripheral descover services", peripheral.services, discoverServiceError)
                if discoverServiceError != nil { return .other(discoverServiceError!)}

                for service in peripheral.services ?? [] {
                    if service.uuid == IMMEDIATE_ALERT_SERVICE {
                        serviceImmediateAlert = service
                    }
                }
            }
            guard let serviceImmediateAlert = serviceImmediateAlert else { return .noImmediateAletService }

            let discoverCharacteristicsError = waitForDiscoverCharacteristics(forService: serviceImmediateAlert, timeout: maxTimeout)
            print("peripheral descover characteristics", serviceImmediateAlert.characteristics, discoverCharacteristicsError)
            if discoverCharacteristicsError != nil { return .other(discoverCharacteristicsError!)}
            for characteristic in serviceImmediateAlert.characteristics ?? [] {
                if characteristic.uuid == ALERT_LEVEL_CHARACTERISTIC {
                    characteristicImmediateAlert = characteristic
                }
            }
        }
        
        if characteristicImmediateAlert == nil { return .noImmediateAletCharacteristic }

        print("peripheral ok")
        return nil
    }
    
    func writeImmediateAlert(volume: AlertVolume) {
        if characteristicImmediateAlert == nil { return }
        peripheral?.writeValue(volume.data, for: characteristicImmediateAlert!, type: .withoutResponse)
    }
}
