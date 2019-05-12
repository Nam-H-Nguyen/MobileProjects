//
//  FIRMessagingService.swift
//  For Sale
//
//  Created by Kyle Lee on 9/17/17.
//  Copyright © 2017 Kyle Lee. All rights reserved.
//

import Foundation
import FirebaseMessaging

enum SubscriptionTopic: String {
    case newProducts = "newProducts"
}

class FIRMessagingService {
    
    private init() {}
    static let shared = FIRMessagingService()
    let messaging = Messaging.messaging()
    
    func subscribe(to topic: SubscriptionTopic) {
        messaging.subscribe(toTopic: topic.rawValue)
    }
    
    func unsubscribe(from topic: SubscriptionTopic) {
        messaging.unsubscribe(fromTopic: topic.rawValue)
    }
}
