//
//  TagFactoryInterface.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

protocol TagFactoryInterface {
    func tag(id: String, name: String) -> TagInterface
    func tag(id: String, dict: [String: Any?]) -> TagInterface
}
