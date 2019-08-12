//
//  BLEConnectionsStoreFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEConnectionsStoreFactoryDefault: BLEConnectionsStoreFactoryInterface {
    func store(connectionFactory: BLEConnectionFactoryInterface, manager: CBCentralManager, peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface) -> BLEConnectionsStoreInterface {
        return BLEConnectionsStoreDefault(connectionFactory: connectionFactory, manager: manager, peripheralObservablesFactory: peripheralObservablesFactory)
    }
}
