//
//  constants.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

let IMMEDIATE_ALERT_SERVICE = CBUUID(string: "00001802-0000-1000-8000-00805f9b34fb")
let FINDME_SERVICE = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")
let ALERT_LEVEL_CHARACTERISTIC = CBUUID(string: "00002a06-0000-1000-8000-00805f9b34fb")
let FINDME_CHARACTERISTIC = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb")
