//
//  ViewController.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/1/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit
import CoreData

// Changed the name of the view controller to JustDoItViewController
class JustDoItViewController: UITableViewController {

//    var itemArray = ["Finish JustDoIt App", "Work on Assignment #2", "Go through Data Structure Code"]
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()
    }

    //MARK - Tableview Datasource Methods
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
    
    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Delete part in CRUD
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        // If user clicks on the cell that already has a checkmark, then it dechecks the checkmark
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done  // Updates the checkmarks
        
        saveItems()
        
        // Once you deselect it won't highlight in gray anymore
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField() // to make textField available to the closures below
        
        let alert = UIAlertController(title: "Are new to-do item", message: "Just Do It", preferredStyle: .alert)
        
        // When user clicks on the Get It Done button on UIAlert
        let action = UIAlertAction(title: "Get it done", style: .default) { (action) in
    
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem) // append user input from the alert
            
            self.saveItems()
            
            self.tableView.reloadData() // input won't be automatically added, so require reloadData function
        }
        
        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Create part in CRUD in CoreData
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // Read part in CRUD in CoreData
    // with = external parameter, request = internal parameter
    // =Item.fetchRequest() is a default value if we don't pass in any initialized value
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        // Fetch data from persistent container
        do {
            // save the fetch to itemArray
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
}

//MARK: - Search Bar methods
// Extension modularizes code for Search Bar
extension JustDoItViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Fetches data
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // Query using the searchBar.text that user types in, %@ substitues any arguments passed in
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
    }
    
    // Once search bar is cleared, load all the items again
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            // Get rid of keyboard and cursor
            DispatchQueue.main.async {
                // Keyboard to dismiss after clearing search bar
                searchBar.resignFirstResponder()
            }
            loadItems()
        }
    }
}

