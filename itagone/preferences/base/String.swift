//
//  String.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

public class StringPreference: AnyPreference {
    func get() -> String? {
        return defaults.string(forKey: key)
    }
    
    func get(_ defVal: String) -> String {
        guard let o = defaults.object(forKey: key) else { return defVal}
        return o as! String
    }

    func set(_ val: String) {
        defaults.set(val, forKey: key)
    }
}
