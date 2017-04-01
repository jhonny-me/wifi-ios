//
//  LocationManaer.swift
//  SaveWifi
//
//  Created by Johnny Gu on 31/03/2017.
//  Copyright © 2017 Johnny Gu. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

final class LocationManager: NSObject {
    static let `default` = LocationManager()
    var canShowNotification = false
    private lazy var manager: CLLocationManager = {
        let newManager = CLLocationManager()
        newManager.requestAlwaysAuthorization()
        return newManager
    }()
    fileprivate var completion: ((CLLocationCoordinate2D) -> Void)?
    
    func startOneUpdate(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        self.completion = completion
        manager.startUpdatingLocation()
        manager.delegate = self
    }
    
    func didEnterAreas(areas: [CLRegion], completion: @escaping () -> ()) {
        areas.forEach {
            manager.startMonitoring(for: $0)
        }
        manager.delegate = self
    }
    
    func area(from location: CLLocationCoordinate2D) -> CLRegion {
        return CLCircularRegion(center: location, radius: 30, identifier: "")
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.delegate = nil
        manager.stopUpdatingLocation()
        guard let location = locations.first else { return }
        completion?(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if canShowNotification {
            canShowNotification = false
            // make the local notification
            if WifiManager.default.isPortableWifi {
                let content = UNMutableNotificationContent()
                content.body = "You are still connect to your portable wifi"
                content.badge = 1
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        canShowNotification = true
    }
}
