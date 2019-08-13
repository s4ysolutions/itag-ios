//
//  Int+extenstions.swift
//  itagone
//
//  Created by  Sergey Dolin on 13/08/2019.
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
