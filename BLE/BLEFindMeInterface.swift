//
//  BLEFindMeInterface.swift
//  BLE
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import Rasat


public protocol BLEFindMeInterface {
    var findMeObservable: Observable<(id: String, findMe: Bool)> { get }
    func isFindMe(id: String) -> Bool
}

protocol BLEFindMeControlInterface {
    func onClick(id: String)
}
