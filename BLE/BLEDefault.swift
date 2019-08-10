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
        finderFactory: BLEAlertFactoryDefault(),
        observer: BLEManagerObserverDefault(),
        peripheralObserverFactory: BLEPeripheralObserverFactoryDefault(),
        scannerFactory: BLEScannerFactoryDefault(),
        storeFactory: BLEConnectionsStoreFactoryDefault()
    )
    
    public let finder: BLEAlertInterface
    public let scanner: BLEScannerInterface
    public var timeout = 60
    
    init(
        connectionFactory: BLEConnectionFactoryInterface,
        finderFactory: BLEAlertFactoryInterface,
        observer: BLEManagerObserverInterface,
        peripheralObserverFactory: BLEPeripheralObserverFactoryInterface,
        scannerFactory: BLEScannerFactoryInterface,
        storeFactory: BLEConnectionsStoreFactoryInterface
        ) {
        
        // NOTE: delegate MUST be of BLEManagerObserverInterface
        let manager = CBCentralManager(delegate: observer, queue: DispatchQueue.global(qos: .background))
        let store = storeFactory.store(connectionFactory: connectionFactory, manager: manager, peripheralObserverFactory: peripheralObserverFactory)
        scanner = scannerFactory.scanner(manager: manager)
        finder = finderFactory.finder(store: store)
    }
    
}
