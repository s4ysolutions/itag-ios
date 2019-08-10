//
//  BLEConnnectionDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation

class BLEConnectionDefault: BLEConnectionInterface {
    var state: BLEConnectionState = .notavailble
    
    func makeAvailabe(completion: () -> Void) {
        
    }
}
