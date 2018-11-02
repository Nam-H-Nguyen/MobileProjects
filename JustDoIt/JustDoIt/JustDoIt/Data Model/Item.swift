//
//  Item.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/1/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import Foundation

// Only encodable, decodable with primitive data types
class Item: Codable {
    var title: String = ""
    var done: Bool = false
}
