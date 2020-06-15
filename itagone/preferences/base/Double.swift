//
//  Double.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

public class DoublePreference: AnyPreference {
    func get() -> Double {
        return defaults.double(forKey: key)
    }
    
    func get(_ defVal: Double) -> Double {
        guard let o = defaults.object(forKey: key) else { return defVal}
        return o as! Double
    }

    func set(_ val: Double) {
        defaults.set(val, forKey: key)
    }
}
