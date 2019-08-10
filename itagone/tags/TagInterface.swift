//
//  Tag.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation

enum TagBindState {
    case NotBind
    case Bind
    case BindAndAlert
}

enum TagConnectionState {
    case NotConnected
    case Connecting
    case Connected
}

enum TagLostState {
    case NotLost
    case Lost
}

enum TagColor {
    case black
    case blue
    case gold
    case green
    case red
    case white
    
    var string: String {
        get {
            switch self {
            case .black:
                return "black"
            case .blue:
                return "blue"
            case .gold:
                return "gold"
            case .green:
                return "green"
            case .red:
                return "red"
            case .white:
                return "white"
            }
        }
    }
    
    static func from(string: String?) -> TagColor {
        switch string {
        case "white":
            return .white
        case "blue":
            return .blue
        case "gold":
            return .gold
        case "green":
            return .green
        case "red":
            return .red
        default:
            return .black
        }
    }
}

protocol TagInterface {
    var id: String { get }
    var name: String { get set }
    var color: TagColor { get set }
    var alert: Bool { get set }
    func toDict() -> [String: Any?]
    func toString() -> String
}
