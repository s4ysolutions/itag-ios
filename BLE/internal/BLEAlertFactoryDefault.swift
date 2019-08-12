//
//  BLEAlertFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEAlertFactoryDefault: BLEAlertFactoryInterface {
    func alert(store: BLEConnectionsStoreInterface) -> BLEAlertInterface {
        return BLEAlertDefault(store: store)
    }
}
