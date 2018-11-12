//
//  AppDelegate.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/1/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Uncomment line below if want to find out where the realm file is
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        // Commit current state to realm data
        do {
            _ = try Realm()
        } catch {
            print("Error intializing new realm, \(error)")
        }
        
        return true
    }
}

