//
//  WayToday.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

class WayTodayPreferences {
    private static let onPref = BoolPreference("waytodayon")
    static var on: Bool {
        get {
            return onPref.get()
        }
        set(val) {
            onPref.set(val)
        }
    }
    static var off: Bool {
        get {
            return !on
        }
        set(val) {
            on = !val
        }
    }
    static func toggle() {
        on = !on
    }
}
