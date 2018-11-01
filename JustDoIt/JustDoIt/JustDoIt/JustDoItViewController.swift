//
//  ViewController.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/1/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit

// Changed the name of the view controller to JustDoItViewController
class JustDoItViewController: UITableViewController {

    let itemArray = ["Finish JustDoIt App", "Work on Assignment #2", "Go through Data Structure Code"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //@TODO - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JustDoItItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        
        // Method tableView expects a return
        return cell
    }
    
    //@TODO - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Print to the console the value of the itemArray
//        print(itemArray[indexPath.row])
        
        // If user clicks on the cell that already has a checkmark, then it dechecks the checkmark
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        // Once you deselect it won't highlight in gray anymore
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

