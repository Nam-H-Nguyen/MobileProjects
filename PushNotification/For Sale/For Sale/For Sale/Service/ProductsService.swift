//
//  ProductsService.swift
//  For Sale
//
//  Created by Kyle Lee on 9/17/17.
//  Copyright © 2017 Kyle Lee. All rights reserved.
//

import Foundation

protocol ProductsServiceDelegate {
    func didChange(products: [Product])
}

class ProductsService {
    
    private init() {}
    static let shared = ProductsService()
    var delegate: ProductsServiceDelegate?
    
    func observeProducts() {
        FIRDatabaseService.shared.observe(.products) { (snapshot) in
            guard let productsSnapshot = ProductsSnapshot(snapshot: snapshot) else { return }
            self.delegate?.didChange(products: productsSnapshot.products)
        }
    }
    
    func post(product: Product) {
        FIRDatabaseService.shared.post(parameters: product.parameters(), to: .products)
    }
    
}
