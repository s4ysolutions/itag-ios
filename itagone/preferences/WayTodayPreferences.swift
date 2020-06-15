//
//  WayToday.swift
//  itagone
//
//  Created by  Sergey Dolin on 15.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

class WayTodayPreferences {
    static let useServicePref = BoolPreference("useWayToday")
    static var useService: Bool {
        get {
            return useServicePref.get(false)
        }
        set (value) {
            useServicePref.set(value)
        }
    }
}
