
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

func getAlertSoundMode() -> AlertSoundMode {
    let defaults = UserDefaults.standard
    let m = defaults.integer(forKey: "alertSoundMode")
    switch m {
    case 1:
        return .Vibration
    case 2:
        return .NoSound
    default:
        return .Sound
    }
}

func setAlertSoundMode(mode: AlertSoundMode) {
    let defaults = UserDefaults.standard
    switch mode {
    case .Sound:
        defaults.set(0, forKey: "alertSoundMode")
    case .Vibration:
        defaults.set(1, forKey: "alertSoundMode")
    case .NoSound:
        defaults.set(2, forKey: "alertSoundMode")
    }
}
