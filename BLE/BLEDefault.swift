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
        connectionsControlFactory: BLEConnectionsControlFactoryDefault(),
        connectionsFactory: BLEConnectionsFactoryDefault(),
        finderFactory: BLEAlertFactoryDefault(),
        findMe: BLEFindMeDefault(),
        findMeControlFactory: BLEFindMeControlFactoryDefault(),
        managerObservables: BLEManagerObservablesDefault(),
        peripheralObservablesFactory: BLEPeripheralObservablesFactoryDefault(),
        scannerFactory: BLEScannerFactoryDefault(),
        storeFactory: BLEConnectionsStoreFactoryDefault()
    )

    private let manager: CBCentralManager
    private let store: BLEConnectionsStoreInterface

    public let alert: BLEAlertInterface
    public let connections: BLEConnectionsInterface
    public let findMe: BLEFindMeInterface
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
        connectionsControlFactory: BLEConnectionsControlFactoryInterface,
        connectionsFactory: BLEConnectionsFactoryInterface,
        finderFactory: BLEAlertFactoryInterface,
        findMe: BLEFindMeInterface,
        findMeControlFactory: BLEFindMeControlFactoryInterface,
        managerObservables: BLEManagerObservablesInterface,
        peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface,
        scannerFactory: BLEScannerFactoryInterface,
        storeFactory: BLEConnectionsStoreFactoryInterface
        ) {

        self.findMe = findMe
        // NOTE: delegate MUST be of BLEManagerObserverInterface
        manager = CBCentralManager(delegate: managerObservables, queue: DispatchQueue.global(qos: .background),options: [CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: "itagone"])
        let findMeControl = findMeControlFactory.findMeControl(findMe: findMe)
        store = storeFactory.store(connectionFactory: connectionFactory, findMeControl: findMeControl, manager: manager, peripheralObservablesFactory: peripheralObservablesFactory)
        connections = connectionsFactory.connections(store: store, managerObservables: managerObservables)
        // this is cycle dependency ugly resolving
        // connections <- store <- connectionsControl <- connections
        // as a result store.setConnections is must
        store.setConnectionsControl(connectionsControl: connectionsControlFactory.connectionsControl(connections: connections))
        alert = finderFactory.alert(store: store)
        scanner = scannerFactory.scanner(connections: connections, manager: manager)

        disposable.add(managerObservables.didUpdateState.subscribe(id: "cb manager state", handler: {state in
            self.stateChannel.broadcast(state == CBManagerState.poweredOn ? .on : .off)
        }))
        
        disposable.add(managerObservables.willRestoreState.subscribe(id: "cb manager restore", handler: {periphirals in
            self.store.restorePeripherals(peripherals: periphirals)
        }))
    }
    
    public var state: BLEState { get {
        return manager.state == CBManagerState.poweredOn ? .on : .off
        }
    }
    
}
