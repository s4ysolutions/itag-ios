//
//  LastSeenLocation.swift
//  itagone
//
//  Created by  Sergey Dolin on 14.06.2020.
//  Copyright © 2020  Sergey Dolin. All rights reserved.
//

import Foundation
import CoreLocation

class LastSeenLocation {
    private let latPref: DoublePreference
    private let lonPref: DoublePreference
    
    init(id: String) {
       latPref = DoublePreference("lastSeenLat\(id)")
       lonPref = DoublePreference("lastSeenLon\(id)")
    }
 
    var coordinate: CLLocationCoordinate2D? {

        get {
            let lat = latPref.get(0)
            let lon = lonPref.get(0)
            if (lat == 0.0 && lon == 0.0) {
                return nil
            }else{
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        
        set(value) {
            if (value == nil) {
                latPref.set(0)
                lonPref.set(0)
            } else {
                latPref.set(value!.latitude)
                lonPref.set(value!.longitude)
            }
        }
    }
}
