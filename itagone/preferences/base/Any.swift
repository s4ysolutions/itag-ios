//
//  Any.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

open class AnyPreference {
    let key: String
    init(_ key: String) {
        self.key = key
    }
    
    var defaults: UserDefaults {
        get {
            return UserDefaults.standard
        }
    }
}
