//
//  VibrationDeafule.swift
//  itagone
//
//  Created by  Sergey Dolin on 12.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation

import AudioToolbox.AudioServices

class VibrationDefault {
    static let shared = VibrationDefault()
    
    private var vibrating = false;
    
    public func start() {
        let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
        vibrating = true
        DispatchQueue.global(qos: .background).async {
            while self.vibrating {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                if (self.vibrating) {
                    Thread.sleep(forTimeInterval: 1)
                }
            }
        }
    }
    
    public func stop() {
        vibrating = false
    }
}
