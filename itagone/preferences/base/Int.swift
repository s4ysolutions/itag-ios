//
//  Integer.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

public class IntPreference: AnyPreference {
    func get() -> Int {
        return defaults.integer(forKey: key)
    }
    
    func get(_ defVal: Int) -> Int {
        guard let o = defaults.object(forKey: key) else { return defVal}
        return o as! Int
    }

    func set(_ val: Int) {
        defaults.set(val, forKey: key)
    }
}
