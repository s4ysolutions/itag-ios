//
//  BLEConnectionFactoryDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEConnectionFactoryDefault: BLEConnectionFactoryInterface {
    func connection(connectionsControl: BLEConnectionsControlInterface, manager: CBCentralManager,   peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface, id: String) -> BLEConnectionInterface {
        return BLEConnectionDefault(connectionsControl: connectionsControl, manager: manager, peripheralObservablesFactory: peripheralObservablesFactory, id: id)
    }
}
