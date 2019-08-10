//
//  BLEConnection.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

enum AlertVolume: Int {
    case NO_ALERT = 0x00
    case MEDIUM_ALERT = 0x01
    case HIGH_ALERT = 0x02
    var data: Data {
        get {
            var value = self.rawValue
            return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        }
    }
}

enum BLEConnectError: Error {
    case timeout
    case noPeripheral
    case badUUID
    case noImmediateAletService
    case noImmediateAletCharacteristic
    case other(_ error: Error)
}

protocol BLEConnectionInterface {
    var isConnected: Bool { get }
    func makeAvailabe(timeout: Int)  -> BLEConnectError?
    func writeImmediateAlert(volume: AlertVolume)
}
