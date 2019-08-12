//
//  BLEConnectionsStoreInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

protocol BLEConnectionsStoreInterface {
    func setConnectionsControl(connectionsControl: BLEConnectionsControlInterface)
    func get(id: String) -> BLEConnectionInterface?
    func getOrMake(id: String) -> BLEConnectionInterface
}
