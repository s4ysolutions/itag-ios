
//
//  AlertSound.swift
//  itagone
//
//  Created by  Sergey Dolin on 12.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

enum AlertSoundMode {
    case Sound
    case Vibration
    case NoSound
}

class AlertSoundPreferences {
    private static let onPref = IntPreference("alertSoundMode")
    static var mode: AlertSoundMode {
        get {
            let m = onPref.get()
            switch m {
            case 1:
                return .Vibration
            case 2:
                return .NoSound
            default:
                return .Sound
            }
        }
        set(val) {
            switch val {
            case .Sound:
                onPref.set(0)
            case .Vibration:
                onPref.set(1)
            case .NoSound:
                onPref.set(2)
            }
        }
    }
    static func next() {
        switch mode {
        case .NoSound:
            mode = .Sound
        case .Sound:
            mode = .Vibration
        case .Vibration:
            mode = .NoSound
        }
    }
}
