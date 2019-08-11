//
//  BLEAlertInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import Rasat

public protocol BLEAlertInterface {
    func isAlerting(id: String) ->  Bool
    func toggleAlert(id: String, timeout: Int)
    func startAlert(id: String, timeout: Int)
    func stopAlert(id: String, timeout: Int)
}
