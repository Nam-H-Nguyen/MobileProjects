//
//  ProductCell.swift
//  For Sale
//
//  Created by Kyle Lee on 9/17/17.
//  Copyright © 2017 Kyle Lee. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = product.price()
    }
    
}
