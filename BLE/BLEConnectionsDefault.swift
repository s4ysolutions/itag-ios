//
//  BLEConnectionsDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

class BLEConnectionsDefault: BLEConnectionsInterface {
    
    let store: BLEConnectionsStoreInterface
    
    init (store: BLEConnectionsStoreInterface) {
        self.store = store
    }
    
    func disconnect(id: String) {
        guard let connection = store.get(id: id) else {return}
        _ = connection.disconnect(timeout: 0)
    }
}
