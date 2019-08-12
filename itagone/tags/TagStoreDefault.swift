//
//  TagStoreDefault.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import BLE
import CoreBluetooth
import Foundation
import Rasat

class TagStoreDefault: TagStoreInterface {
    static let shared = TagStoreDefault(factory: TagFactoryDefault.shared, ble: BLEDefault.shared)
    
    let ble: BLEInterface
    let channel = Channel<StoreOp>()
    let defaults = UserDefaults.standard
    let factory: TagFactoryInterface

    var ids = [String]()
    var idsforever = [String]()
    var tags = [String: TagInterface]()
    
    init(factory: TagFactoryInterface, ble: BLEInterface) {
        self.factory = factory
        self.ble = ble
 
        ids = defaults.array(forKey: "ids") as? [String] ?? []
        idsforever = defaults.array(forKey: "idsforever") as? [String] ?? []
        print("tag ids <- store:", ids)
        print("tag idsforever <- store:", idsforever)
        
        for id in idsforever {
            guard let dict = defaults.dictionary(forKey: "tag \(id)") else {continue}
            if ids.contains(id) {
                tags[id] = factory.tag(id: id, dict: dict)
                print("tag remembered <- store:", tags[id]?.toString() ?? "", dict)
            } else {
                print("tag forgotten <- store:", tags[id]?.toString() ?? "", dict)
            }
        }
    }
    
    func by(id: String) -> TagInterface? {
        return tags[id]
    }
    
    func everBy(id: String) -> TagInterface? {
        let active = by(id: id)
        if active != nil {
            return active
        }
        
        guard let dict = defaults.dictionary(forKey: "tag \(id)") else {return nil}
        return factory.tag(id: id, dict: dict)
    }
    
    func tagBy(pos: Int) -> TagInterface? {
        if pos >= ids.count {
            return nil
        }
        return by(id: ids[pos])
    }
    
    var count: Int {
        get {
            return ids.count
        }
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
        defaults.set(idsforever, forKey: "idsforever")
        print("tag ids -> store:", ids)
        print("tag ids forever -> store:", idsforever)

        for id in ids {
            guard let tag = tags[id] else { continue }
            defaults.set(tag.toDict(), forKey: "tag \(id)")
            print("tag -> store:", tags[id]?.toString() ?? "",tag.toDict())
        }
    }
    
    func remember(tag: TagInterface) {
        if !ids.contains(tag.id) {
            ids.append(tag.id)
        }
        
        if !idsforever.contains(tag.id) {
            idsforever.append(tag.id)
        }
        
        if let existing = everBy(id: tag.id) {
            tag.copy(fromTag:existing)
        }

        tags[tag.id] = tag
        
        storeToDefaults()
        channel.broadcast(.remember(tag))
    }
    
    func forget(id: String) {
        if let i = ids.firstIndex(of: id) {
            ids.remove(at: i)
            storeToDefaults()
            if tags[id] != nil {
                channel.broadcast(.forget(tags[id]!))
            }
        }
    }
    
    func remembered(id: String) -> Bool {
        return ids.contains(id)
    }

    func set(alert: Bool, forTag: TagInterface) {
        // TODO: report if not found
        guard var tag = tags[forTag.id] else { return }
        tag.alert = alert
        storeToDefaults()
        channel.broadcast(.change(tag))
    }
    
    func set(color: TagColor, forTag: TagInterface) {
        // TODO: report if not found
        guard var tag = tags[forTag.id] else { return }
        tag.color = color
        storeToDefaults()
        channel.broadcast(.change(tag))
    }
    
    func set(name: String, forTag: TagInterface) {
        // TODO: report if not found
        guard var tag = tags[forTag.id] else { return }
        tag.name = name
        storeToDefaults()
        // important: broadacst even the same value
        // beacase alert state depends on connect state
        channel.broadcast(.change(tag))
    }

    func connectAll() {
        print("connect all ble", ids)
        for (_, tag) in tags {
            if tag.alert {
                ble.connect(id: tag.id,timeout: 10)
            }
        }
    }
}
