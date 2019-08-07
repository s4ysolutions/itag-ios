//
//  BLE.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import CoreBluetooth
import Rasat

let SCAN_TIMEOUT = 60

protocol BLE {
    var scannerTimerObservable: Observable<Int> { get }
    var scannerObservable: Observable<CBPeripheral> { get }
    var isScanning: Bool { get }
    var scanningTimeout: Int { get }
    var state: CBManagerState { get }
    func startScan(timeout: Int)
    func stopScan()
}
