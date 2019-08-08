//
//  TagDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

class TagDefault: TagInterface {
    let id: String
    var name: String
    
    init(id: String, name: String?) {
        self.id = id
        self.name = name ?? "unknown".localized
    }
    
    init(id: String, dict: [String: Any?]) {
        self.id =  id
        self.name = (dict["name"] ?? "unknonw".localized) as! String
    }
    
    func toDict() -> [String: Any?] {
        return ["id": id, "name": name]
    }
}
