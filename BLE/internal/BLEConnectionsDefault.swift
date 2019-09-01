//
//  BLEConnectionsDefault.swift
//  BLE
//
//  Created by  Sergey Dolin on 11/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import Foundation
import Rasat

private class StatesHolder {
    var states: [String: BLEConnectionState] = [:]
}

private class ConnectionsStateArrayDefault: BLEConnectionStateArray {
    var holder: StatesHolder
    init (holder: StatesHolder) {
        self.holder = holder
    }
    subscript(id: String) -> BLEConnectionState {
        return holder.states[id] ?? .disconnected
    }
}

class BLEConnectionsDefault: BLEConnectionsInterface, BLEConnectionsControlInterface {
    let disposables = DisposeBag()
    let managerObservables: BLEManagerObservablesInterface
    let state: BLEConnectionStateArray
    let store: BLEConnectionsStoreInterface
    private var holder = StatesHolder()
    
    init (store: BLEConnectionsStoreInterface, managerObservables: BLEManagerObservablesInterface) {
        self.store = store
        self.managerObservables = managerObservables
        self.state = ConnectionsStateArrayDefault(holder: holder)
        disposables.add(managerObservables.didConnectPeripheral.subscribe(handler: {peripheral in
            self.setState(id: peripheral.identifier.uuidString, state: .connected)
        }))
        disposables.add(managerObservables.didDisconnectPeripheral.subscribe(handler: {tuple in
            self.setState(id: tuple.peripheral.identifier.uuidString, state: .disconnected)
        }))
        disposables.add(managerObservables.didFailToConnectPeripheral.subscribe(handler: {tuple in
            self.setState(id: tuple.peripheral.identifier.uuidString, state: .disconnected)
        }))
    }
    
    func disconnect(id: String) {
        let connection = store.getOrMake(id: id)
        _ = connection.disconnect(timeout: 0)
    }
    
    func connect(id: String) {
        let connection = store.getOrMake(id: id)
        _ = connection.connect()
    }
    
    func startListen(id: String, timeout: Int) {
        let connection = store.getOrMake(id: id)
        _ = connection.makeAvailabe(timeout: timeout)
    }

    let stateObservableChannel = Channel<(id: String, fromState: BLEConnectionState, toState: BLEConnectionState)>()
    var stateObservable: Observable<(id: String, fromState: BLEConnectionState, toState: BLEConnectionState)> {
        get {
            return stateObservableChannel.observable
        }
    }
    
    let setStateQueue = DispatchQueue(label: "setState")
    func setState(id: String, state: BLEConnectionState) {
        let fromState: BLEConnectionState = holder.states[id] ?? .unknown
        
        if state == fromState { return }
        
        setStateQueue.sync {
            holder.states[id] = state
        }
        print("connection state changed", id, state)
        stateObservableChannel.broadcast((id: id, fromState: fromState, toState: state))
    }
    
}
