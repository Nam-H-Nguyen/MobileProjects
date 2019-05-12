//
//  ViewController.swift
//  Moti
//
//  Created by NomNomNam on 5/1/19.
//  Copyright © 2019 NomNomNam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNService.shared.authorize()
        CLService.shared.authorize()
    }

    @IBAction func onTimerTapped() {
        print("Timer tapped")
    }
    
    @IBAction func onDateTapped() {
        print("Date tapped")

    }
    
    @IBAction func onLocationTapped() {
        print("Location tapped")

    }
}

