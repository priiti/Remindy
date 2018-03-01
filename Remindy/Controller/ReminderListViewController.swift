//
//  ReminderListViewController.swift
//  Remindy
//
//  Created by Priit Pärl on 18/02/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import UIKit
import CoreData

class ReminderListViewController: UITableViewController {

    var itemsList: [ReminderItem] = [ReminderItem]()
    
    var selectedCategory: Category? {
        didSet {
            loadItemsData()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderItemCell", for: indexPath)
        
        let singleReminderItem = itemsList[indexPath.row]
        
        cell.textLabel?.text = singleReminderItem.title
        
        cell.accessoryType = singleReminderItem.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // context.delete(itemsList[indexPath.row])
        // itemsList.remove(at: indexPath.row)
        
        
        itemsList[indexPath.row].done = !itemsList[indexPath.row].done
        
        saveItemsData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new reminder", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in

            let newItem = ReminderItem(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemsList.append(newItem)
            
            self.saveItemsData()
        }
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new item"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model methods
    
    fileprivate func saveItemsData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    fileprivate func loadItemsData(with request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest(),
                                   predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
       
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemsList = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search bar functionality
extension ReminderListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItemsData(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItemsData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
