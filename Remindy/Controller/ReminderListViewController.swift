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
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadItemsData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Tableview Datasource Methods
    
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
    
    //MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // context.delete(itemsList[indexPath.row])
        // itemsList.remove(at: indexPath.row)
        
        
        itemsList[indexPath.row].done = !itemsList[indexPath.row].done
        
        saveItemsData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new reminder", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in

            let newItem = ReminderItem(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemsList.append(newItem)
            
            self.saveItemsData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Model methods
    
    fileprivate func saveItemsData() {
        
        do {
            try self.context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    fileprivate func loadItemsData() {
        let request: NSFetchRequest<ReminderItem> = ReminderItem.fetchRequest()
        
        do {
            itemsList = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
    }
}
