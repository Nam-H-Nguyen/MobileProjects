//
//  Item.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/9/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import Foundation
import RealmSwift

// Used for Realm to persist data
class Item: Object {
    // Dynamic dispatch allows property name to be monitored for change at runtime
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    // Category.self = Object.type
    // Propery: "items" = points to forward relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
