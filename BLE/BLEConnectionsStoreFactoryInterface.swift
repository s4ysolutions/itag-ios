//
//  BLEConnectionsStoreFactoryInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

protocol BLEConnectionsStoreFactoryInterface {
    func store(connectionFactory: BLEConnectionFactoryInterface, manager: CBCentralManager, peripheralObserverFactory: BLEPeripheralObserverFactoryInterface) -> BLEConnectionsStoreInterface
}
