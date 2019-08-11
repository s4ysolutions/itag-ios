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
        connectionFactory: BLEConnectionFactoryDefault(),
        connectionsFactory: BLEConnectionsFactoryDefault(),
        finderFactory: BLEAlertFactoryDefault(),
        observer: BLEManagerObservablesDefault(),
        peripheralObserverFactory: BLEPeripheralObserverFactoryDefault(),
        scannerFactory: BLEScannerFactoryDefault(),
        storeFactory: BLEConnectionsStoreFactoryDefault()
    )

    private let manager: CBCentralManager
    private let store: BLEConnectionsStoreInterface

    public let alert: BLEAlertInterface
    public let connections: BLEConnectionsInterface
    public let scanner: BLEScannerInterface
    public var stateObservable: Observable<BLEState> { get {
        return stateChannel.observable
        }
    }
    public var timeout = 60
    
    let disposable = DisposeBag()
    let stateChannel = Channel<BLEState>()

    init(
        connectionFactory: BLEConnectionFactoryInterface,
        connectionsFactory: BLEConnectionsFactoryInterface,
        finderFactory: BLEAlertFactoryInterface,
        observer: BLEManagerObservablesInterface,
        peripheralObserverFactory: BLEPeripheralObserverFactoryInterface,
        scannerFactory: BLEScannerFactoryInterface,
        storeFactory: BLEConnectionsStoreFactoryInterface
        ) {
        
        // NOTE: delegate MUST be of BLEManagerObserverInterface
        manager = CBCentralManager(delegate: observer, queue: DispatchQueue.global(qos: .background))
        store = storeFactory.store(connectionFactory: connectionFactory, manager: manager, peripheralObserverFactory: peripheralObserverFactory)
        scanner = scannerFactory.scanner(manager: manager)
        alert = finderFactory.finder(store: store)
        connections = connectionsFactory.connections(store: store)
        disposable.add(observer.didUpdateState.subscribe(id: "BLE", handler: {state in
            self.stateChannel.broadcast(state == CBManagerState.poweredOn ? .on : .off)
        }))
    }
    
    public func connect(id: String, timeout: Int) {
        let connection = store.getOrMake(id: id)
        connection.makeAvailabe(timeout: timeout)
    }
    
    public var state: BLEState { get {
        return manager.state == CBManagerState.poweredOn ? .on : .off
        }
    }
    
}
