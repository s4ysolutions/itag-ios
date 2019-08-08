//
//  TagStoreDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import Foundation
import Rasat

class TagStoreDefault: TagStoreInterface {
    static let shared = TagStoreDefault(factory: TagFactoryDefault())
    
    let channel = Channel<StoreOp>()
    let factory: TagFactoryInterface
    let defaults = UserDefaults()
    var tags = [String: TagInterface]()
    var ids = [String]()
    
    init(factory: TagFactoryInterface) {
        self.factory = factory
        ids = defaults.array(forKey: "ids") as? [String] ?? []
        for id in ids {
            let dict = defaults.dictionary(forKey: "tag \(id)")
            if dict != nil {
                tags[id] = factory.tag(id: id, dict: dict!)
            }
        }
        print("tag ids in store:", ids)
        print("tags in store:", tags)
    }
    
    subscript(id: String) -> TagInterface? {
        return tags[id]
    }
 
    var observable: Observable<StoreOp> {
        get{
            return channel.observable
        }
    }
    
    /*
    private func clearDefaults() {
        defaults.removeObject(forKey: "ids")
        for id in ids {
            defaults.removeObject(forKey: "tag \(id)")
        }
    }*/
    
    private func storeToDefaults() {
        defaults.set(ids, forKey: "ids")
        for id in ids {
            guard let tag = tags[id] else { continue }
            defaults.set(tag.toDict(), forKey: "tag \(id)")
        }
    }
    
    func remember(tag: TagInterface) {
        if !ids.contains(tag.id) {
            ids.append(tag.id)
            tags[tag.id] = tag
            storeToDefaults()
            print("tag ids in store after append", ids)
            print("tags in store after append", tags)
            channel.broadcast(StoreOp.remember)
        }
    }
    
    func forget(id: String) {
        if let i = ids.firstIndex(of: id) {
            ids.remove(at: i)
            storeToDefaults()
            print("tag ids in store after remove", ids)
            print("tags in store after remove", tags)
            channel.broadcast(StoreOp.forget)
        }
    }
    
    func remembered(id: String) -> Bool {
        return ids.contains(id)
    }

}
