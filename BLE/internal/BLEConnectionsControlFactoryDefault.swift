//
//  BLEConnectionsControlFactoryDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

class BLEConnectionsControlFactoryDefault: BLEConnectionsControlFactoryInterface {
    func connectionsControl(connections: BLEConnectionsInterface) -> BLEConnectionsControlInterface {
        return connections as! BLEConnectionsControlInterface
    }
}
