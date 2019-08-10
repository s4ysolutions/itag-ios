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
    func connection(manager: CBCentralManager, peripheralObserverFactory: BLEPeripheralObserverFactoryInterface, id: String) -> BLEConnectionInterface {
        return BLEConnectionDefault(manager: manager, peripheralObserverFactory: peripheralObserverFactory, id: id)
    }
}
