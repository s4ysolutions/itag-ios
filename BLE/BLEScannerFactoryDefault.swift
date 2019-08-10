//
//  BLEScannerFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEScannerFactoryDefault: BLEScannerFactoryInterface {
    func scanner(manager: CBCentralManager, observer: BLEObserverInterface) -> BLEScannerInterface {
        return BLEScannerDefault(manager: manager, observer: observer)
    }
}
