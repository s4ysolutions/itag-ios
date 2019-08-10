//
//  BLEConnectionFactory.swift
//  itagone
//
//  Created by  Sergey Dolin on 10/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

protocol BLEConnectionFactoryInterface {
    func connection(id: String) -> BLEConnectionInterface
}
