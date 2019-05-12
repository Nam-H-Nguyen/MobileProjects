//
//  UNService.swift
//  Moti
//
//  Created by NomNomNam on 5/1/19.
//  Copyright © 2019 NomNomNam. All rights reserved.
//

import Foundation
import UserNotifications

class UNService: NSObject {
    
    private override init() {}
    // add singleton instance when working with data / threads
    static let shared = UNService()
    
    let userNC = UNUserNotificationCenter.current()
    
    // Request permission from user
    func authorize() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .carPlay]
        userNC.requestAuthorization(options: options) { (granted, error) in
            print(error ?? "No UN auth error")
            guard granted else {
                print("USER DENIED ACCESs")
                return
            }
            
            self.configure()
        }
    }
    
    // Only runs when user grants permission
    func configure() {
        userNC.delegate = self
//        setupActionsAndCategories()
    }
    
    func timerRequest(with interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "Your timer is all done. YAY!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "userNotification.timer",
                                            content: content,
                                            trigger: trigger)
        
        userNC.add(request)
    }
    
    func dateRequest(with components: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "Date Trigger"
        content.body = "It is now the future!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "userNotification.date",
                                            content: content,
                                            trigger: trigger)
        userNC.add(request)
    }
    
    func locationRequst() {
        let content = UNMutableNotificationContent()
        content.title = "You have returned"
        content.body = "Welcome back you silly coder you!"
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: "userNotification.location",
                                            content: content,
                                            trigger: nil)
        
        userNC.add(request)
    }

}

extension UNService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UN service received response")
        
        completionHandler();
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("UN service will present notification")
        
        let options: UNNotificationPresentationOptions = [.alert, .sound]
        
        completionHandler(options)
    }
}

