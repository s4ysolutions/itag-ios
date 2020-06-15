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
    let disposables = DisposeBag()
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
    
    init(connectionsControl: BLEConnectionsControlInterface, findMeControl: BLEFindMeControlInterface ,manager: CBCentralManager, peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface, id: String) {
        self.connectionsControl = connectionsControl
        self.id = id
        self.manager = manager
        self.peripheralObservables = peripheralObservablesFactory.observables()
        // NOTE: manager.delegate must be BLEManagerObserverInterface
        self.managerObservervables = manager.delegate as! BLEManagerObservablesInterface
        disposables.add(peripheralObservables.didUpdateValueForCharacteristic.subscribe(
            on: DispatchQueue.global(qos: .background),
            handler: {tuple in
                if tuple.peripheral.identifier == self.peripheral?.identifier &&
                    tuple.characteristic.uuid == FINDME_CHARACTERISTIC
                {
                    findMeControl.onClick(id: tuple.peripheral.identifier.uuidString)
                }
        }))
    }
    
    init(connectionsControl: BLEConnectionsControlInterface, findMeControl: BLEFindMeControlInterface ,manager: CBCentralManager, peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface, peripheral: CBPeripheral) {
        self.connectionsControl = connectionsControl
        self.id = peripheral.identifier.uuidString
        self._peripheral = peripheral
        // deligator will be set before discoverin
        // sanity assignment
        self._peripheral!.delegate = nil
        self.manager = manager
        self.peripheralObservables = peripheralObservablesFactory.observables()
        // NOTE: manager.delegate must be BLEManagerObserverInterface
        self.managerObservervables = manager.delegate as! BLEManagerObservablesInterface
        disposables.add(peripheralObservables.didUpdateValueForCharacteristic.subscribe(
            on: DispatchQueue.global(qos: .background),
            handler: {tuple in
                if tuple.peripheral.identifier == self.peripheral?.identifier &&
                    tuple.characteristic.uuid == FINDME_CHARACTERISTIC
                {
                    findMeControl.onClick(id: tuple.peripheral.identifier.uuidString)
                }
        }))
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
    
    var findMeService : CBService? {
        get {
            guard let peripheral = peripheral else {return nil}
            for service in peripheral.services ?? [] {
                if service.uuid == FINDME_SERVICE {
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
    
    var findMeCharacteristic: CBCharacteristic? {
        get {
            guard let service = findMeService else {return nil}
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == FINDME_CHARACTERISTIC {
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
        if peripheral.state == .connected { return nil }
        
        connectionsControl.setState(id: id, state: .connecting)
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
        // TODO: abort abother scan?
        connectionsControl.setState(id: id, state: .discovering)
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
        manager.scanForPeripherals(withServices: [IMMEDIATE_ALERT_SERVICE, FINDME_SERVICE])
        if semaphore.wait(timeout: timeout) == .timedOut {
            manager.stopScan();
            return .timeout
        }
        manager.stopScan();
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
        
        peripheral.discoverServices([IMMEDIATE_ALERT_SERVICE, FINDME_SERVICE])
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
    
    private func assertPeripheral() -> BLEError? {
        if peripheral == nil {
            guard let uuid = UUID(uuidString: id) else { return .badUUID }
            let known = manager.retrievePeripherals(withIdentifiers: [uuid])
            if known.count > 0 {
                peripheral = known[0]
            } else {
                peripheral = manager.retrieveConnectedPeripherals(withServices: []).first(where: {connected in connected.identifier == uuid})
            }
            /*
            if let peripheral = peripheral {
                let state: BLEConnectionState = {
                    switch peripheral.state {
                    case .connected:
                        return BLEConnectionState.connected
                    case .connecting:
                        return BLEConnectionState.connecting
                    case .disconnected:
                        return BLEConnectionState.disconnected
                    case.disconnecting:
                        return BLEConnectionState.connecting
                    default:
                        return BLEConnectionState.disconnected
                    }
                }()
                connectionsControl.setState(id: id, state: state)
            }*/
        }
        return nil
    }
    
    func makeAvailabe(timeout: Int) -> BLEError? {
        manager.stopScan()
        _ = assertPeripheral()
        
        if peripheral != nil {
            if waitForConnect(timeout: timeout.dispatchTime) != nil {
                peripheral = nil
            }
        }

        defer {
            let connected =
                peripheral != nil &&
                peripheral!.state == .connected &&
                immediateAlertCharacteristic != nil &&
                findMeCharacteristic != nil

            connectionsControl.setState(id: id, state:connected ? .connected : .disconnected)
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
        
        guard let serviceImmediateAlert = immediateAlertService else { return .noImmediateAlertService }
        
        if immediateAlertCharacteristic == nil {
            let discoverCharacteristicsError = waitForDiscoverCharacteristics(forService: serviceImmediateAlert, timeout: maxTimeout)
            if discoverCharacteristicsError != nil { return .other(discoverCharacteristicsError!)}
        }
        if immediateAlertCharacteristic == nil { return .noImmediateAlertCharacteristic }

        guard let serviceFindMe = findMeService else { return .noFindMeAlertService}
        if findMeCharacteristic == nil {
            let discoverCharacteristicsError = waitForDiscoverCharacteristics(forService: serviceFindMe, timeout: maxTimeout)
            if discoverCharacteristicsError != nil { return .other(discoverCharacteristicsError!)}
        }

        guard let findMeCharacteristic = findMeCharacteristic else { return .noFindMeAlertCharacteristic }

        _ = setNotify(true, characteristic: findMeCharacteristic)
        return nil
    }

    
    func connect() -> BLEError? {
        manager.stopScan()
        connectionsControl.setState(id: id, state: .connecting)
        _ = assertPeripheral()

        if peripheral == nil {
            let disposable = DisposeBag()
            let semaphore = DispatchSemaphore(value: 0)
            disposable.add(managerObservervables.didDiscoverPeripheral.subscribe(handler: {tuple in
                if tuple.peripheral.identifier.uuidString == self.id {
                    self.peripheral = tuple.peripheral
                    semaphore.signal()
                }
            }))
            defer {
                disposable.dispose()
            }
            manager.scanForPeripherals(withServices: [IMMEDIATE_ALERT_SERVICE, FINDME_SERVICE])
            semaphore.wait() // TODO: timeout?
        }
        guard let peripheral = peripheral else {
            connectionsControl.setState(id: id, state: .disconnected)
            return .noPeripheral
        }
        manager.connect(peripheral, options: [:])
        return nil
    }
    
    func disconnect(timeout: Int) -> BLEError? {
        let err = assertPeripheral()
        if err != nil {return err }
        guard let peripheral = peripheral else { return .noPeripheral}
        
        if peripheral.state == .disconnected || peripheral.state == .disconnecting {
            return nil
        }
        
        connectionsControl.setState(id: id, state: .disconnecting)
        if timeout <= 0 {
            // must unsubscribe before connect
            if immediateAlertCharacteristic != nil {
                _ = setNotify(false, characteristic: immediateAlertCharacteristic!)
            }
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

        connectionsControl.setState(id: peripheral.identifier.uuidString, state: .writting)
        if timeout == nil {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            Thread.sleep(forTimeInterval: 0.05)
            connectionsControl.setState(id: peripheral.identifier.uuidString, state: peripheral.state == .connected ? .connected : .disconnected)
        } else {
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
        if immediateAlertCharacteristic == nil { return .noImmediateAlertCharacteristic}
        return write(data: volume.data, characteristic: immediateAlertCharacteristic!, timeout: timeout == 0 ? nil : timeout.dispatchTime)
    }
    
    func writeImmediateAlert(volume: AlertVolume) -> BLEError? {
        return writeImmediateAlert(volume: volume, timeout: 0)
    }
}
