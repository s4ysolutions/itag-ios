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
    func connection(connectionsControl: BLEConnectionsControlInterface, findMeControl: BLEFindMeControlInterface, manager: CBCentralManager, peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface, peripheral: CBPeripheral) -> BLEConnectionInterface {
        <#code#>
    }
    
    func connection(connectionsControl: BLEConnectionsControlInterface, findMeControl: BLEFindMeControlInterface, manager: CBCentralManager,   peripheralObservablesFactory: BLEPeripheralObservablesFactoryInterface, id: String) -> BLEConnectionInterface {
        return BLEConnectionDefault(connectionsControl: connectionsControl, findMeControl: findMeControl, manager: manager, peripheralObservablesFactory: peripheralObservablesFactory, id: id)
    }
}
