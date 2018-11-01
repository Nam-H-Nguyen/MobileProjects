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

    var itemArray = ["Finish JustDoIt App", "Work on Assignment #2", "Go through Data Structure Code"]
    
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // to make textField available to the closures below
        
        let alert = UIAlertController(title: "Add New JustDoIt Item", message: "Get Shit Done", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            self.itemArray.append(textField.text!) // append user input from the alert
            self.tableView.reloadData() // input won't be automatically added, so require reloadData function
        }
        
        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

