//
//  BLE.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//


import CoreBluetooth
import Foundation
import Rasat

let SCAN_TIMEOUT = 60

public protocol BLEInterface {
//    var state: CBManagerState { get }
    var scanner: BLEScannerInterface { get }
    /*
    var scannerTimerObservable: Observable<Int> { get }
    var scannerObservable: Observable<CBPeripheral> { get }
    var isScanning: Bool { get }
    var scanningTimeout: Int { get }
    func startScan(timeout: Int)
    func stopScan()
    func startCallTag(id: String)
 */
}
