//
//  AppDelegate.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreLocation
import BLE
import UIKit
import Rasat
import WayTodaySDK

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
let DELAY_BEFORE_REMEMBER_LAST_LOCATION = 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let ble = BLEDefault.shared
    let dispose = DisposeBag()
    let store = TagStoreDefault.shared
    let sound = SoundDefault.shared
    let vibation = VibrationDefault.shared;
    
    let wtLog: Log
    let locationService: LocationService
    let uploader: Uploader
    let wayTodayState: WayTodayState
    var window: UIWindow?
    
    let l = Logger("AppDelegate")
    private let locationManager = CLLocationManager()
    
    override init(){
        wtLog = LogDefault.shared
        wayTodayState = WayTodayStateDefault.shared
        uploader = UploaderDefault.shared(log: wtLog, wayTodayState: wayTodayState)
        locationService = LocationServiceDefault.shared(log: wtLog, wayTodayState: wayTodayState)
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dispose.add(ble.connections.stateObservable.subscribe(id: "connect/disconnect", handler: {(id: String, fromState: BLEConnectionState, toState: BLEConnectionState) in
            if toState == .disconnected {
                if !self.store.remembered(id: id) {
                    return;
                }
                guard let tag = self.store.by(id: id) else { return }
                if !tag.alert { return }
                DispatchQueue.global(qos: .background).async {
                    self.ble.connections.connect(id: id) // wait forever
                }
                DispatchQueue.global(qos: .background).asyncAfter(deadline: DELAY_BEFORE_REMEMBER_LAST_LOCATION.dispatchTime) {
                    let state = self.ble.connections.state[id]
                    if state == .disconnected || state == .connecting {
                        let lsl = LastSeenLocation(id: id)
                        lsl.coordinate = self.locationService.lastLocation?.coordinate
                    }
                }
                DispatchQueue.global(qos: .background).asyncAfter(deadline: DELAY_BEFORE_ALERT.dispatchTime) {
                    if self.ble.connections.state[id] != .connected {
                        switch AlertSoundPreferences.mode {
                        case .Sound:
                            self.sound.startLost()
                            break
                        case .Vibration:
                            self.vibation.start()
                            break;
                        case .NoSound:
                            break;
                        }
                    }
                }
            } else if (toState == .connected && fromState != .writting ){
                self.sound.stop()
                self.vibation.stop()
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
            self.setupLocationService()
        }))
        dispose.add(store.observable.subscribe(on: DispatchQueue.global(qos: .background), id: "remember/forget", handler: {op in
            defer {
                self.setupLocationService()
            }
            switch op {
            case .remember(let tag):
                if (tag.alert) {
                    self.ble.connections.connect(id: tag.id)
                }
                return
            case .forget(let tag ):
                self.ble.connections.disconnect(id: tag.id)
                return
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
                                                                self.vibation.stop()
                                                            }
        }))
        
        dispose.add(locationService.observableStatus.subscribe(handler: {status in
            self.l.d("locationService status: \(status)")
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                switch status {
                case .stopped:
                    if self.wayTodayState.on {
                        if self.locationService.authorizationStatus != .Authorized {
                            self.locationService.requestAuthorization()
                        }
                    }
                case .needAuthorization, .unknown:
                    self.locationManager.requestAlwaysAuthorization()
                case .disabled:
                    break
                case .started:
                    break
                case .problem:
                    break
                }
            }
        
        }))
        
        if ble.state == .on {
            DispatchQueue.global(qos: .background).async {
                self.store.connectAll()
            }
        }
        
        if wayTodayState.on {
            do {
                try uploader.startListen(locationService: locationService, wayTodayService: WayTodayServiceDefault.shared(log: wtLog, wayTodayState: WayTodayStateDefault.shared, appname: WAYTODAY_APPNAME, secret: WAYTODAY_SECRET, provider: WAYTODAY_PROVIDER))
            }catch{
                wtLog.error("Error start listening")
            }
        }
        
        setupLocationService();
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        ble.scanner.stop()
        DispatchQueue.global(qos: .background).async {
            self.store.stopAlertAll()
        }
        sound.stop()
        vibation.stop()
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
        uploader.stopListen()
    }
    
    private func setupLocationService() {
        let hasAlerts = store.hasAlerts
        let useWayToday = wayTodayState.on
        if (hasAlerts || useWayToday) && ble.state == .on  {
            l.d("locationService.start hasAlerts=\(hasAlerts) useWayToday=\(useWayToday) ble=\(ble.state)")
            locationService.start()
        } else {
            l.d("locationService.stop hasAlerts=\(hasAlerts) useWayToday=\(useWayToday) ble=\(ble.state)")
            locationService.stop()
        }
        
    }
    
}

