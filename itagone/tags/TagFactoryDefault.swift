//
//  TagFactoryDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

class TagFactoryDefault: TagFactoryInterface {
    static let shared = TagFactoryDefault()
    
    func tag(id: String, name: String) -> TagInterface {
        return TagDefault(id: id, name: name)
    }
    
    func tag(id: String, dict: [String: Any?]) -> TagInterface {
        return TagDefault(id: id, dict: dict)
    }

}
