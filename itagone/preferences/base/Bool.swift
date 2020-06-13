//
//  Boolean.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

public class BoolPreference: AnyPreference {
    
    func get() -> Bool {
        return defaults.bool(forKey: key)
    }
    
    func get(_ defVal: Bool) -> Bool {
        guard let o = defaults.object(forKey: key) else { return defVal}
        return o as! Bool
    }

    func set(_ val: Bool) {
        defaults.set(val, forKey: key)
    }
}
