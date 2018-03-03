//
//  CategoryViewController.swift
//  Remindy
//
//  Created by Priit Pärl on 01/03/2018.
//  Copyright © 2018 Priit Pärl. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryList: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryData()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryList?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.categoryCellColor) else { fatalError() }
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.accessoryType = .none
            cell.backgroundColor = categoryColor
        } else {
            cell.textLabel?.text = "No categories added"
            cell.backgroundColor = UIColor(hexString: "3D53FF")
        }
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    fileprivate func saveCategoryData(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    fileprivate func loadCategoryData() {
        categoryList = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let deletableCategory = self.categoryList?[indexPath.row] {
            do {
                let deletableChildItems = deletableCategory.reminderItems
                try realm.write {
                    realm.delete(deletableChildItems)
                }
                try realm.write {
                    realm.delete(deletableCategory)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.categoryCellColor = UIColor.randomFlat.hexValue()
            
            self.saveCategoryData(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToReminderItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ReminderListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryList?[indexPath.row]
        }
    }
}
