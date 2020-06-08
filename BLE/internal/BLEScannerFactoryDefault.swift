//
//  BLEScannerFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEScannerFactoryDefault: BLEScannerFactoryInterface{
    func scanner(connections: BLEConnectionsInterface, manager: CBCentralManager) -> BLEScannerInterface {
        // TODO: i do not know what does it mean ".self as! BLEConnectionsInterface"
        return BLEScannerDefault(connections: connections, manager: manager)
    }
}
