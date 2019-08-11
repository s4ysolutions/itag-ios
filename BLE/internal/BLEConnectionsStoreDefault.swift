//
//  BLEConnectionsStoreDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEConnectionsStoreDefault: BLEConnectionsStoreInterface {
    let connectionFactory: BLEConnectionFactoryInterface
    let manager: CBCentralManager
    let peripheralObserverFactory: BLEPeripheralObserverFactoryInterface

    var map: [String: BLEConnectionInterface] = [:]

    init(connectionFactory: BLEConnectionFactoryInterface, manager: CBCentralManager, peripheralObserverFactory: BLEPeripheralObserverFactoryInterface) {
        self.connectionFactory = connectionFactory
        self.peripheralObserverFactory = peripheralObserverFactory
        self.manager = manager
    }
    
    func get(id: String) -> BLEConnectionInterface? {
        return map[id]
    }
    
    func getOrMake(id: String) -> BLEConnectionInterface {
        if map[id] == nil || !map[id]!.isConnected {
             map[id] = connectionFactory.connection(
                manager: manager,
                peripheralObserverFactory: peripheralObserverFactory,
                id: id)
        }
        return map[id]!
    }
}
