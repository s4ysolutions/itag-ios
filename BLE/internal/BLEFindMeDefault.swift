//
//  BLEFindMeDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import Rasat

class BLEFindMeDefault: BLEFindMeInterface, BLEFindMeControlInterface {
    let clicksChannel = Channel<BLEFindMeClicks> ()
    var clicksObservable: Observable<BLEFindMeClicks> {
        get {
            return clicksChannel.observable
        }
    }
    
    func onClick(id: String) {
        clicksChannel.broadcast(.oneClick)
    }
}
