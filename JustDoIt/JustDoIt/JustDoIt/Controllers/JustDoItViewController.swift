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

//    var itemArray = ["Finish JustDoIt App", "Work on Assignment #2", "Go through Data Structure Code"]
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Finish JustDoIt App"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Work on Assignment #2"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Go through Data Structure Code"
        itemArray.append(newItem3)
        
        if let items = defaults.array(forKey: "JustDoItListArray") as? [Item] {
            itemArray = items;
        }
    }

    //@TODO - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JustDoItItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //@TODO - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Print to the console the value of the itemArray
//        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        // If user clicks on the cell that already has a checkmark, then it dechecks the checkmark
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        // Once you deselect it won't highlight in gray anymore
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // to make textField available to the closures below
        
        let alert = UIAlertController(title: "Add New JustDoIt Item", message: "Get Shit Done", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem) // append user input from the alert
            self.defaults.set(self.itemArray, forKey: "JustDoItListArray")
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

