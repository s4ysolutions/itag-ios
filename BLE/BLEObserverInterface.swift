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

protocol BLEObserverInterface {
    var delegate: CBCentralManagerDelegate { get }
//    var scannerChannel: Channel<CBPeripheral> { get }
//    var scannerTimerObservable: Observable<Int> { get }
    var scanObservable: Observable<CBPeripheral> { get }
}
