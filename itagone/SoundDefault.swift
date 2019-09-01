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
    static let shared = SoundDefault()
    
    var player: AVAudioPlayer?
    
    var isPlaying: Bool {
        get {
            return player != nil
        }
    }
    func startLost() {
        start(name: "lost")
    }
    func startFindMe() {
        start(name: "findme")
    }
    
    private func start(name: String) {
        stop()
        DispatchQueue.main.sync {
            if let asset = NSDataAsset(name: name){
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    player = try AVAudioPlayer(data:asset.data, fileTypeHint: AVFileType.mp3.rawValue)
                    player?.prepareToPlay()
                    player?.numberOfLoops = -1
                    player?.play()
                }catch let error as NSError {
                    print(error, error.code, error.description)
                }
            }else{
                print("no lost")
            }
        }
    }
    
    func stop() {
        player?.stop()
        player=nil
    }
}
