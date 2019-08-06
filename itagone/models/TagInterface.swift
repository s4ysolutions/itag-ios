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

protocol TagInterface {
    var bindState: TagBindState {get set}
    var connectionState: TagConnectionState {get set}
    var lostState: TagLostState {get set}
}
