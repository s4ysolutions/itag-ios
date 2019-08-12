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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let ble = BLEDefault.shared
    let dispose = DisposeBag()
    let store = TagStoreDefault.shared

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ble.state == .on {
            DispatchQueue.global(qos: .background).async {
                self.store.connectAll()
            }
        }
        dispose.add(ble.connections.stateObservable.subscribe(handler: {(id: String, state: BLEConnectionState) in
            if state == .disconnected {
                guard let tag = self.store.by(id: id) else { return }
                if !tag.alert { return }
                DispatchQueue.global(qos: .background).async {
                    self.ble.connections.connect(id: id) // wait forever
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
        dispose.add(store.observable.subscribe(on: DispatchQueue.global(qos: .background), handler: {op in
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
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        dispose.dispose()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

