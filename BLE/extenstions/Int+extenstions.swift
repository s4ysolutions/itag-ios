//
//  Int+extenstions.swift
//  BLE
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

extension Int {
    var dispatchTime: DispatchTime {
        get {
            return DispatchTime.now() + .seconds(self)
        }
    }
}
