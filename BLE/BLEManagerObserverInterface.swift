//
//  BLEObserverInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

protocol BLEManagerObserverInterface: CBCentralManagerDelegate {
    var connectObservable: Observable<CBPeripheral> { get }
    var connectErrorObservable: Observable<(CBPeripheral,Error?)> { get }
    var discoverObservable: Observable<(CBPeripheral, [String: Any], NSNumber)> { get }
}
