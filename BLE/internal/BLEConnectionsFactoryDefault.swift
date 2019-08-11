//
//  BLEConnectionsFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

class BLEConnectionsFactoryDefault: BLEConnectionsFactoryInterface {
    func connections(store: BLEConnectionsStoreInterface) -> BLEConnectionsInterface {
        return BLEConnectionsDefault(store: store)
    }
}
