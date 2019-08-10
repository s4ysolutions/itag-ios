//
//  BLEPeripheralObserverInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

protocol BLEPeripheralObserverInterface: CBPeripheralDelegate {
    var discoverServicesObservable: Observable<CBPeripheral> { get }
    var discoverCharacteristicsObservable: Observable<(CBPeripheral, CBService, Error?)> { get }
}
