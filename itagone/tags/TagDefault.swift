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
    var color: TagColor
    var alert: Bool
    
    init(id: String, name: String?, color: TagColor?, alert: Bool?) {
        self.id = id
        self.name = name ?? "unknown".localized
        self.color = color ?? .black
        self.alert = alert ?? false
    }
    
    init(id: String, dict: [String: Any?]) {
        self.id =  id
        self.name = dict["name"] as? String ?? "unknown".localized
        self.color = TagColor.from(string: dict["color"] as? String ?? nil)
        self.alert = dict["alert"] as? Bool ?? false
    }
    
    func toDict() -> [String: Any?] {
        return ["id": id, "name": name, "color": color.string, "alert": alert]
    }
    
    
    func toString() -> String {
        return "id: \(id), name: \(name), color: \(color.string), alert: \(alert)"
    }
    
    func copy(fromTag: TagInterface) {
        name = fromTag.name
        color = fromTag.color
        alert = fromTag.alert
    }
}
