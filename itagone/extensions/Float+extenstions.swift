//
//  Float+extenstions.swift
//  itagone
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

extension Float {
    var dispatchTime: DispatchTime {
        get {
            return DispatchTime.now() + .milliseconds(Int(self*1000))
        }
    }
}
