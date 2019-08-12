//
//  BLEScannerInterface.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

public protocol BLEScannerInterface {
    var isScanning: Bool { get }
    var scanningTimeout: Int { get }
    var timerObservable: Observable<Int> { get }
    var peripheralsObservable: Observable<(peripheral: CBPeripheral, data: [String: Any], rssi: NSNumber)> { get }

    func start(timeout: Int, forceCancelIds: [String])
    func stop()
    
}
