//
//  ProductsSnapshot.swift
//  For Sale
//
//  Created by Kyle Lee on 9/17/17.
//  Copyright © 2017 Kyle Lee. All rights reserved.
//

import Foundation
import Firebase

struct ProductsSnapshot {
    let products: [Product]
    
    init?(snapshot: DataSnapshot) {
        guard let snapDict = snapshot.value as? [String: [String: Any]] else { return nil }
        var products = [Product]()
        for snap in snapDict {
            guard let product = Product(valueDict: snap.value) else { continue }
            products.append(product)
        }
        self.products = products
    }
}
