//
//  AppDelegate.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import BLE
import UIKit
import Rasat

enum ApplicationState {
    case ACTIVE
    case INACTIVE
}

let applicationStateChannel = Channel<ApplicationState>()
var applicationStateObservable: Observable<ApplicationState> {
    get {
        return applicationStateChannel.observable
    }
}

let DELAY_BEFORE_ALERT = 3
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let ble = BLEDefault.shared
    let dispose = DisposeBag()
    let store = TagStoreDefault.shared
    let sound = SoundDefault.shared

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ble.state == .on {
            DispatchQueue.global(qos: .background).async {
                self.store.connectAll()
            }
        }
        dispose.add(ble.connections.stateObservable.subscribe(id: "connect/disconnect", handler: {(id: String, fromState: BLEConnectionState, toState: BLEConnectionState) in
            if toState == .disconnected {
                guard let tag = self.store.by(id: id) else { return }
                if !tag.alert { return }
                DispatchQueue.global(qos: .background).async {
                    self.ble.connections.connect(id: id) // wait forever
                }
                DispatchQueue.global(qos: .background).asyncAfter(deadline: DELAY_BEFORE_ALERT.dispatchTime) {
                    if self.ble.connections.state[id] != .connected {
                        self.sound.startLost()
                    }
                }
            } else if (toState == .connected && fromState != .writting ){
                self.sound.stop()
                guard let tag = self.store.by(id: id) else { return }
                if tag.alert {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: 0.5.dispatchTime){
                        self.ble.connections.startListen(id: id, timeout: BLE_TIMEOUT)
                    }
                }
            }
        }))
        dispose.add(ble.stateObservable.subscribe(id: "BLE powered on", handler: {state in
            if state == .on {
                DispatchQueue.global(qos: .background).async {
                    self.store.connectAll()
                }
            }
        }))
        dispose.add(store.observable.subscribe(on: DispatchQueue.global(qos: .background), id: "remember/forget", handler: {op in
            switch op {
            case .remember(_):
                return
            case .forget(let tag ):
                self.ble.connections.disconnect(id: tag.id)
            case .change(let tag ):
                if (tag.alert) {
                    self.ble.connections.connect(id: tag.id)
                } else {
                    self.ble.connections.disconnect(id: tag.id)
                }
                return
            }
        }))
        dispose.add(ble.findMe.findMeObservable.subscribe(on: DispatchQueue.global(qos: .background),
                                                          id: "find me",
                                                          handler: {tuple in
                                                            if (tuple.findMe) {
                                                                self.sound.startFindMe()
                                                            } else {
                                                                self.sound.stop()
                                                            }
        }))
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        ble.scanner.stop()
        DispatchQueue.global(qos: .background).async {
            self.store.stopAlertAll()
        }
        sound.stop()
        applicationStateChannel.broadcast(.INACTIVE)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        applicationStateChannel.broadcast(.ACTIVE)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        dispose.dispose()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

