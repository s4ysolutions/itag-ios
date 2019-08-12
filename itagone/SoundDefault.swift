//
//  sound.swift
//  itagone
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit




class SoundDefault {
    var player: AVAudioPlayer?
    func start() {
        DispatchQueue.main.sync {
        if let asset = NSDataAsset(name:"lost"){
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = try AVAudioPlayer(data:asset.data, fileTypeHint: AVFileType.mp3.rawValue)
                player?.prepareToPlay()
                player?.play()
            }catch let error as NSError {
                print(error)
            }
        }else{
            print("no lost")
        }
        }
    }
    
    func stop() {
        player?.stop()
    }
}
