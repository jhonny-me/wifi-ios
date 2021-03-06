//
//  AppDelegate.swift
//  SaveWifi
//
//  Created by Johnny Gu on 30/03/2017.
//  Copyright © 2017 Johnny Gu. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (bool, result) in
            print(bool, result)
        }
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let areas = AppDelegate.locations.map {
            LocationManager.default.area(from: $0)
        }
        LocationManager.default.didEnterAreas(areas: areas) {
            
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

extension AppDelegate {
    static var ssid: String? {
        get {
            return UserDefaults.standard.string(forKey: "com.johnny.ssid")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "com.johnny.ssid")
        }
    }
    static var locations: [CLLocationCoordinate2D] {
        get {
            guard let locations = UserDefaults.standard.value(forKey: "com.johnny.locations") as? [[String: CLLocationDegrees]] else { return [] }
            return locations.flatMap(CLLocationCoordinate2D.init)
        }
        set {
            UserDefaults.standard.set(newValue.map {$0.archive()}, forKey: "com.johnny.locations")
        }
    }
}

