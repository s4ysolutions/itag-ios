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

class BLEConnectionDefault: BLEConnectionInterface {
    let connectionsControl: BLEConnectionsControlInterface
    let id: String
    let manager: CBCentralManager
    let managerObservervables: BLEManagerObservablesInterface
    let peripheralObservables: BLEPeripheralObservablesInterface
    
    var _peripheral: CBPeripheral?
    var immediateAlertDispose: Disposable?
    
    var peripheral: CBPeripheral? {
        get {
            return _peripheral
        }
        set (p){
            _peripheral = p
            immediateAlertDispose?.dispose()
            if p == nil {
                immediateAlertDispose = nil
            } else {
                immediateAlertDispose = peripheralObservables.didWriteValueForCharacteristic.subscribe(handler: {tuple in
                    if tuple.peripheral.identifier == p!.identifier &&
                        tuple.characteristic.uuid == ALERT_LEVEL_CHARACTERISTIC {
                        self.immediateAlertUpdateNotificationChannel.broadcast((id: p!.identifier.uuidString, tuple.characteristic.value?.alertVolume ?? .NO_ALERT))
                    }
                })
            }
        }
    }
    
    init(connectionsControl: BLEConnectionsControlInterface, manager: CBCentralManager, peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface, id: String) {
        self.connectionsControl = connectionsControl
        self.id = id
        self.manager = manager
        self.peripheralObservables = peripheralObservablesFactory.observables()
        // NOTE: manager.delegate must be BLEManagerObserverInterface
        self.managerObservervables = manager.delegate as! BLEManagerObservablesInterface
    }
    
    var hasPeripheral: Bool {get{
            return peripheral != nil
        }
    }
    var isConnected: Bool {
        get{
            return peripheral != nil && peripheral?.state == .connected
        }
    }
    
    var immediateAlertService : CBService? {
        get {
            guard let peripheral = peripheral else {return nil}
            for service in peripheral.services ?? [] {
                if service.uuid == IMMEDIATE_ALERT_SERVICE {
                    return service
                }
            }
            return nil
        }
    }
    
    var immediateAlertCharacteristic: CBCharacteristic? {
        get {
            guard let service = immediateAlertService else {return nil}
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == ALERT_LEVEL_CHARACTERISTIC {
                    return characteristic
                }
            }
            return nil
        }
    }
    
    let immediateAlertUpdateNotificationChannel = Channel<(id: String, volume: AlertVolume)>()
    var immediateAlertUpdateNotification: Observable<(id: String, volume: AlertVolume)> { get {
        return immediateAlertUpdateNotificationChannel.observable
        }}
    
    private func waitForConnect(timeout: DispatchTime) -> BLEError? {
        guard let peripheral = peripheral else {return .noPeripheral}
        connectionsControl.setState(id: peripheral.identifier.uuidString, state: .connecting)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let disposable = DisposeBag()
        var errorConnect: Error? = nil
        
        disposable.add(managerObservervables.didConnectPeripheral.subscribe(handler: { connected in
            if connected.identifier == peripheral.identifier {
                semaphore.signal()
            }
        }))
        
        disposable.add(managerObservervables.didFailToConnectPeripheral.subscribe(handler: { tuple in
            if tuple.peripheral.identifier == peripheral.identifier {
                errorConnect = tuple.error
                semaphore.signal()
                self.manager.cancelPeripheralConnection(tuple.peripheral)
            }
        }))
        
        defer {
            disposable.dispose()
        }
        manager.connect(peripheral, options: [:])
        if semaphore.wait(timeout: timeout) == .timedOut {
            self.manager.cancelPeripheralConnection(peripheral)
            return .timeout
        }
        
        if errorConnect != nil { return .other(errorConnect!)}
        return nil
    }
    
    private func waitForDiscover(timeout: DispatchTime) -> BLEError? {
        connectionsControl.setState(id: id, state: .connecting)
        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        disposable.add(managerObservervables.didDiscoverPeripheral.subscribe(handler: {tuple in
            if tuple.peripheral.identifier.uuidString == self.id {
                self.peripheral = tuple.peripheral
                semaphore.signal()
            }
        }))
        defer {
            disposable.dispose()
        }
        manager.scanForPeripherals(withServices: [IMMEDIATE_ALERT_SERVICE])
        if semaphore.wait(timeout: timeout) == .timedOut {
            return .timeout
        }
        return nil
    }
    
    private func waitForDiscoverServices(timeout: DispatchTime) -> BLEError?  {
        guard let peripheral = peripheral else { return .noPeripheral}
        connectionsControl.setState(id: peripheral.identifier.uuidString, state: .discoveringServices)

        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        let observer = peripheral.delegate as! BLEPeripheralObservablesInterface
        disposable.add(observer.didDiscoverServices.subscribe(handler: {discovered in
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
    
    
    private func waitForDiscoverCharacteristics(forService: CBService, timeout: DispatchTime) -> BLEError?  {
        guard let peripheral = peripheral else { return .noPeripheral}
        connectionsControl.setState(id: peripheral.identifier.uuidString, state:
            .discoveringCharacteristics)

        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        var discoverError: Error? = nil
        
        let observer = peripheral.delegate as! BLEPeripheralObservablesInterface
        disposable.add(observer.didDiscoverCharacteristicsForService.subscribe(handler: {tuple in
            if tuple.peripheral.identifier == peripheral.identifier && tuple.service.uuid == forService.uuid {
                discoverError = tuple.error
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
        
        if discoverError != nil {
            return .other(discoverError!)
        }
        
        return nil
    }
    
    func makeAvailabe(timeout: Int) -> BLEError? {
        if peripheral == nil {
            guard let uuid = UUID(uuidString: id) else { return .badUUID }
            let known = manager.retrievePeripherals(withIdentifiers: [uuid])
            if known.count > 0 {
                peripheral = known[0]
                if waitForConnect(timeout: timeout.dispatchTime) != nil {
                    peripheral = nil
                }
            } else {
                peripheral = manager.retrieveConnectedPeripherals(withServices: []).first(where: {connected in connected.identifier == uuid})
                if peripheral != nil {
                    if waitForConnect(timeout: timeout.dispatchTime) != nil {
                        peripheral = nil
                    }
                }
            }
        }
        
        let maxTimeout = timeout.dispatchTime
        if peripheral == nil {
            let scanError = waitForDiscover(timeout: maxTimeout)
            if scanError != nil { return .other(scanError!)}
            let connectError = waitForConnect(timeout: maxTimeout)
            if connectError != nil { return .other(connectError!)}
        }
        
        guard let peripheral = peripheral else {return .noPeripheral}
        if peripheral.delegate == nil {
            peripheral.delegate = peripheralObservables
        }
        
        if immediateAlertService == nil {
            let discoverServiceError = waitForDiscoverServices(timeout: maxTimeout)
            if discoverServiceError != nil { return .other(discoverServiceError!)}
        }
        
        guard let serviceImmediateAlert = immediateAlertService else { return .noImmediateAletService }
        if immediateAlertCharacteristic == nil {
            let discoverCharacteristicsError = waitForDiscoverCharacteristics(forService: serviceImmediateAlert, timeout: maxTimeout)
            if discoverCharacteristicsError != nil { return .other(discoverCharacteristicsError!)}
        }
        
        if immediateAlertCharacteristic == nil { return .noImmediateAletCharacteristic }
        
        connectionsControl.setState(id: peripheral.identifier.uuidString, state: .connected)
        return nil
    }
    
    func connect() -> BLEError? {
        if peripheral == nil {
            guard let uuid = UUID(uuidString: id) else { return .badUUID }
            let known = manager.retrievePeripherals(withIdentifiers: [uuid])
            if known.count > 0 {
                peripheral = known[0]
            } else {
                peripheral = manager.retrieveConnectedPeripherals(withServices: []).first(where: {connected in connected.identifier == uuid})
            }
        }
        guard let peripheral = peripheral else { return .noPeripheral }
        manager.connect(peripheral, options: [:])
        return nil
    }
    
    func disconnect(timeout: Int) -> BLEError? {
        guard let peripheral = peripheral else { return .noPeripheral}
        connectionsControl.setState(id: peripheral.identifier.uuidString, state: .writting)
        
        if timeout <= 0 {
            manager.cancelPeripheralConnection(peripheral)
            return nil
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        var disconnectError: Error? = nil
        
        let observer = manager.delegate as! BLEManagerObservablesInterface
        disposable.add(observer.didDisconnectPeripheral.subscribe(handler: {tuple in
            if tuple.peripheral.identifier == peripheral.identifier {
                disconnectError = tuple.error
                semaphore.signal()
            }
        }))
        defer {
            disposable.dispose()
            connectionsControl.setState(id: peripheral.identifier.uuidString, state: peripheral.state == .connected ? .connected : .disconnected)
        }
        
        // must unsubscribe before connect
        if immediateAlertCharacteristic != nil {
            _ = setNotify(false, characteristic: immediateAlertCharacteristic!)
        }
        
        manager.cancelPeripheralConnection(peripheral)
        
        if semaphore.wait(timeout: timeout.dispatchTime) == .timedOut {
            return .timeout
        }
        
        if disconnectError != nil {
            return .other(disconnectError!)
        }
        
        return nil
    }
    
    private func write(data: Data, characteristic: CBCharacteristic, timeout: DispatchTime?) -> BLEError? {
        guard let peripheral = peripheral else { return .noPeripheral}

        if timeout == nil {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            connectionsControl.setState(id: peripheral.identifier.uuidString, state: .writting)
            let semaphore = DispatchSemaphore(value: 0)
            let disposable = DisposeBag()
            
            var writeError: Error? = nil
            
            let observer = peripheral.delegate as! BLEPeripheralObservablesInterface
            disposable.add(observer.didWriteValueForCharacteristic.subscribe(handler: {tuple in
                if tuple.peripheral.identifier == peripheral.identifier && tuple.characteristic.uuid == characteristic.uuid {
                    writeError = tuple.error
                    semaphore.signal()
                }
            }))
            defer {
                disposable.dispose()
                connectionsControl.setState(id: peripheral.identifier.uuidString, state: peripheral.state == .connected ? .connected : .disconnected)
            }
            
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            
            if semaphore.wait(timeout: timeout!) == .timedOut {
                return .timeout
            }
            
            if writeError != nil {
                return .other(writeError!)
            }
        }
        
        return nil
    }
    
    private func setNotify(_ enabled: Bool, characteristic: CBCharacteristic) -> BLEError? {
        guard let peripheral = peripheral else { return .noPeripheral}
        peripheral.setNotifyValue(enabled, for: characteristic)
        return nil
    }
    
    private func read(characteristic: CBCharacteristic, timeout: DispatchTime) -> BLEError? {
        guard let peripheral = peripheral else { return .noPeripheral}
        connectionsControl.setState(id: peripheral.identifier.uuidString, state: .reading)
        
        let semaphore = DispatchSemaphore(value: 0)
        let disposable = DisposeBag()
        
        var readError: Error? = nil
        
        let observer = peripheral.delegate as! BLEPeripheralObservablesInterface
        disposable.add(observer.didUpdateValueForCharacteristic.subscribe(handler: {tuple in
            if tuple.peripheral.identifier == peripheral.identifier && tuple.characteristic.uuid == characteristic.uuid {
                readError = tuple.error
                semaphore.signal()
            }
        }))
        defer {
            disposable.dispose()
            connectionsControl.setState(id: peripheral.identifier.uuidString, state: peripheral.state == .connected ? .connected : .disconnected)
        }
        
        peripheral.readValue(for: characteristic)
        
        if semaphore.wait(timeout: timeout) == .timedOut {
            return .timeout
        }
        
        if readError != nil {
            return .other(readError!)
        }
        
        return nil
    }
    
    func writeImmediateAlert(volume: AlertVolume, timeout: Int)  -> BLEError? {
        if immediateAlertCharacteristic == nil { return .noImmediateAletCharacteristic}
        return write(data: volume.data, characteristic: immediateAlertCharacteristic!, timeout: timeout == 0 ? nil : timeout.dispatchTime)
    }
    
    func writeImmediateAlert(volume: AlertVolume) -> BLEError? {
        return writeImmediateAlert(volume: volume, timeout: 0)
    }
}
