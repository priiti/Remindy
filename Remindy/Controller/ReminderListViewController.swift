//
//  ReminderListViewController.swift
//  Remindy
//
//  Created by Priit Pärl on 18/02/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import UIKit

class ReminderListViewController: UITableViewController {

    var itemsList: [ReminderItem] = [ReminderItem]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
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
        
        itemsList[indexPath.row].done = !itemsList[indexPath.row].done
        
        saveItemsData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new reminder", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            let newItem = ReminderItem(title: textField.text!)
            
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
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemsList)
            
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    fileprivate func loadItemsData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            
            let decoder = PropertyListDecoder()
            
            do {
                itemsList = try decoder.decode([ReminderItem].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
}
