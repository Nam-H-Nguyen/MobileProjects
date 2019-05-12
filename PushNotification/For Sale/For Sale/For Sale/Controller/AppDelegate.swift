//
//  AppDelegate.swift
//  For Sale
//
//  Created by Kyle Lee on 9/17/17.
//  Copyright © 2017 Kyle Lee. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNService.shared.authorize()
        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("did register for notifications")
        print(deviceToken.reduce(""){$0 + String(format: "%02X", $1)})
    }
}
