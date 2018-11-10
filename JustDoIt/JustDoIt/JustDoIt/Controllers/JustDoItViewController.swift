//
//  ViewController.swift
//  JustDoIt
//
//  Created by NomNomNam on 11/1/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit
import RealmSwift

// Changed the name of the view controller to JustDoItViewController
class JustDoItViewController: UITableViewController {


    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    // Attribute used when the category is selected
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    // Access a singleton as AppDelegate to tap into persistent container lazy var
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }

    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JustDoItItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done  // toggles checkmarks in item list
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        // Delete part in CRUD
//        context.delete(todoItems[indexPath.row])
//        todoItems.remove(at: indexPath.row)
        // If user clicks on the cell that already has a checkmark, then it dechecks the checkmark
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done  // Updates the checkmarks
        
//        saveItems()
        
        // Once you deselect it won't highlight in gray anymore
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField() // to make textField available to the closures below
        
        let alert = UIAlertController(title: "Are new to-do item", message: "Just Do It", preferredStyle: .alert)
        
        // When user clicks on the Get It Done button on UIAlert
        let action = UIAlertAction(title: "Get it done", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }

            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Create part in CRUD in CoreData
//    func saveItems() {
//
//        do {
//            try context.save()
//        } catch {
//            print("Error saving context \(error)")
//        }
//
//        self.tableView.reloadData()
//    }
    
    // Read part in CRUD in CoreData
    // with = external parameter, request = internal parameter
    // =Item.fetchRequest() is a default value if we don't pass in any initialized value
//    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
//        // Ensure loaded item matches with the parent category
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        // Optional binding to make sure never unwrapping nil value
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//        // Fetch data from persistent container
//        do {
//            // save the fetch to todoItems
//            todoItems = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar methods
// Extension modularizes code for Search Bar
//extension JustDoItViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        // Fetches data
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        // Query using the searchBar.text that user types in, %@ substitues any arguments passed in
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
//    }
//
//    // Once search bar is cleared, load all the items again
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//
//            // Get rid of keyboard and cursor
//            DispatchQueue.main.async {
//                // Keyboard to dismiss after clearing search bar
//                searchBar.resignFirstResponder()
//            }
//
//        }
//    }
//}

