//
//  BLEConnection.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

enum BLEError: Error {
    case timeout
    case noPeripheral
    case badUUID
    case noImmediateAletService
    case noImmediateAletCharacteristic
    case other(_ error: Error)
}

protocol BLEConnectionInterface {
    var isConnected: Bool { get }
    var immediateAlertUpdateNotification: Observable<(id: String, volume: AlertVolume)> { get }
    var hasPeripheral: Bool {get}
    func connect() -> BLEError?
    func disconnect(timeout: Int) -> BLEError?
    func makeAvailabe(timeout: Int)  -> BLEError?
    func writeImmediateAlert(volume: AlertVolume, timeout: Int)  -> BLEError?
    func writeImmediateAlert(volume: AlertVolume) -> BLEError?
}
