//
//  BLEFindMeDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import Rasat

let CLICK_DELAY: Float = 0.6
enum BLEFindMeClicks {
    case oneClick
    case doubleClick
    case tripleClick
}

class BLEFindMeDefault: BLEFindMeInterface, BLEFindMeControlInterface {
    
    let findMeChannel = Channel<(id: String, findMe: Bool)> ()
    var findMeObservable: Observable<(id: String, findMe: Bool)> {
        get {
            return findMeChannel.observable
        }
    }
    
    let findMeQueue = DispatchQueue(
        label: "solutions.s4y.findMeQueue",
        attributes: .concurrent)
    var unsafeFindMe: Set<String> = []
    
    func isFindMe(id: String) -> Bool {
        var findMe: Bool!
        findMeQueue.sync {
            findMe = unsafeFindMe.contains(id)
        }
        return findMe
    }
    
    func setFindMe(id: String) {
        _ = findMeQueue.sync {
            unsafeFindMe.insert(id)
        }
    }
    
    func unsetFindMe(id: String) {
        _ = findMeQueue.sync {
            unsafeFindMe.remove(id)
        }
    }
    
    let clicksQueue = DispatchQueue(
        label: "solutions.s4y.clicksQueue",
        attributes: .concurrent)
    var unsafeClicks: [String: Int] = [:]
    
    func incClick(_ id: String) -> Int {
        var clicked: Int!
        clicksQueue.sync {
            if unsafeClicks[id] == nil {
                clicked = 1
            } else {
                clicked = unsafeClicks[id]! + 1
            }
            unsafeClicks[id] = clicked
        }
        return clicked
    }
    
    func clearClick(_ id: String) {
        clicksQueue.sync {
            unsafeClicks[id] = 0
        }
    }
    
    func clicked(_ id: String) -> Int {
        var clicked: Int!
        clicksQueue.sync {
            if unsafeClicks[id] == nil {
                clicked = 0
            } else {
                clicked = unsafeClicks[id]!
            }
        }
        return clicked
    }
    
    func clicksToClick(clicks: Int) -> BLEFindMeClicks {
        var click: BLEFindMeClicks
        switch clicks {
        case 2: click = .doubleClick
        case 3: click = .tripleClick
        default: click = .oneClick
        }
        return click
    }
    
    func onClick(id: String) {
        let clicks = incClick(id)
        if clicks == 1 {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: CLICK_DELAY.dispatchTime) {
                let click = self.clicksToClick(clicks: self.clicked(id))
                self.clearClick(id)
                
                if self.isFindMe(id: id) {
                    self.unsetFindMe(id: id)
                    self.findMeChannel.broadcast((id: id, findMe: false))
                } else {
                    if click == .doubleClick || click == .tripleClick {
                        self.setFindMe(id: id)
                        self.findMeChannel.broadcast((id: id, findMe: true))
                    }
                }
            }
        }
    }
}
