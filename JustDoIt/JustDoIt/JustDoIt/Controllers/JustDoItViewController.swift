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
//                    realm.delete(item)
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
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
                        newItem.dateCreated = Date()
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
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar methods
// Extension modularizes code for Search Bar
extension JustDoItViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    // Once search bar is cleared, load all the items again
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            // Get rid of keyboard and cursor
            DispatchQueue.main.async {
                // Keyboard to dismiss after clearing search bar
                searchBar.resignFirstResponder()
            }

        }
    }
}

