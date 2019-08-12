//
//  BLEPeripheralObserverFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

class BLEPeripheralObservablesFactoryDefault: BLEPeripheralObservablesFactoryInterface {
    func observables() -> BLEPeripheralObservablesInterface {
        return BLEPeripheralObservablesDefault()
    }
}
