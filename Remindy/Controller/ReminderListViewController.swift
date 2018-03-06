//
//  ReminderListViewController.swift
//  Remindy
//
//  Created by Priit Pärl on 18/02/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ReminderListViewController: SwipeTableViewController {

    var itemsList: Results<ReminderItem>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            updateViewBackgroundColor(withHexCode: selectedCategory?.categoryCellColor)
            loadItemsData()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.categoryCellColor else { fatalError() }
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: HexColor.defaultBackgroundColor.rawValue)
    }
    
    //MARK: - Color Setup Methods
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        title = selectedCategory?.name
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let singleReminderItem = itemsList?[indexPath.row] else {
            cell.textLabel?.text = "No items added"
            cell.backgroundColor = UIColor.white
            return cell
        }
        
        cell.textLabel?.text = singleReminderItem.title
        
        guard let selectedCategoryColor = selectedCategory?.categoryCellColor else {
            return cell
        }
        
        guard let color = UIColor(hexString: selectedCategoryColor)?.darken(
            byPercentage: CGFloat(indexPath.row) / CGFloat((itemsList?.count)!)) else {
            return cell
        }
        
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        cell.accessoryType = singleReminderItem.done ? .checkmark : .none
        cell.tintColor = ContrastColorOf(color, returnFlat: true)
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemsList?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new reminder", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let item = ReminderItem()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        currentCategory.reminderItems.append(item)
                    }
                } catch {
                    print("Error saving new items: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            textField = alertTextField
            alertTextField.placeholder = "Create new item"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model methods
    fileprivate func loadItemsData() {
        itemsList = selectedCategory?.reminderItems.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let deletableReminderItem = itemsList?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(deletableReminderItem)
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
}

//MARK: - Search bar functionality
extension ReminderListViewController: UISearchBarDelegate, ViewDelegate {
    func updateViewBackgroundColor(withHexCode colorHexCode: String?) {
        guard let bgColor = colorHexCode else {
            view.backgroundColor = UIColor.white
            return
        }
        view.backgroundColor = UIColor(hexString: bgColor)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemsList = itemsList?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
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
