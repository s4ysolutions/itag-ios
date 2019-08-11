//
//  BLEAlertInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

public protocol BLEAlertInterface {
    func toggleAlert(id: String, timeout: Int)
    func startAlert(id: String, timeout: Int)
    func stopAlert(id: String, timeout: Int)
}
