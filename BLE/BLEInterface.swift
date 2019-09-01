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

public enum BLEState {
    case on
    case off
}

public protocol BLEInterface {
    var alert: BLEAlertInterface { get }
    var connections: BLEConnectionsInterface { get }
    var findMe: BLEFindMeInterface { get }
    var scanner: BLEScannerInterface { get }
    var state: BLEState { get }
    var stateObservable: Observable<BLEState> { get }
    var timeout: Int { get set }

  //  func connect(id: String, timeout: Int)
}
