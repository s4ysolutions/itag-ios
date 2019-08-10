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
    var timeout: Int { get set }
    var scanner: BLEScannerInterface { get }
    var finder: BLEAlertInterface { get }
}
