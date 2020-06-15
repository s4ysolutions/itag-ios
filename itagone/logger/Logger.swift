//
//  Log.swift
//  itagone
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import os

public class Logger {
    private let key: String
    
    init(_ key: String = "itagone") {
        self.key = key
    }
    
    public func d(_ msg: String) {
        os_log("%s: %s", log: OSLog.default, type: .debug, key, msg)
    }
    
    public func d(format: String, _ args: CVarArg...) {
        let m = String(format: format, args)
        os_log("%s: %s", log: OSLog.default, type: .debug, key, m)
    }
    
    public func e(_ msg: String) {
        os_log("%s: %s", log: OSLog.default, type: .error, key, msg)
    }
    
    public func e(format: String, _ args: CVarArg...) {
        let m = String(format: format, args)
        os_log("%s: %s", log: OSLog.default, type: .error, key, m)
    }
    
}
