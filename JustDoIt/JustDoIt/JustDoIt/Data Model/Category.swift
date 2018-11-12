//
//  Category.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/9/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    
    // List comes from Realm, which is a container type like an array
    let items = List<Item>()    // initialize empty list
    
}
