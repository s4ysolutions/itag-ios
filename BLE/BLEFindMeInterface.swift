//
//  BLEFindMeInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import Rasat

public enum BLEFindMeClicks {
    case oneClick
    case doubleClick
    case tripleClick
}

public protocol BLEFindMeInterface {
    var clicksObservable: Observable<BLEFindMeClicks> { get }
}

protocol BLEFindMeControlInterface {
    func onClick(id: String)
}
