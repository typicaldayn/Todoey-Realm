//
//  ViewController.swift
//  Todoey-Realm
//
//  Created by Stas Bezhan on 20.07.2022.
//
import ChameleonFramework
import SwipeCellKit
import RealmSwift
import UIKit

class CategoryTVC: SwipeTableVC {
    
    let realm = try! Realm()
    var arrayOfCategories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exist")}
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hexString: "1D9BF6")
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: appearance.backgroundColor!, returnFlat: true)]
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }
    
    //refreshing table view
    @objc func refresh(_ sender: AnyObject) {
        loadCategories()
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        //new alert
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        alert.addTextField() {(alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            if alertTextField.text != nil && alertTextField.text != "" {
                textField.text = alertTextField.text
            }
        }
        
        //actions for alert
        let add = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.hexColor = RandomFlatColor().hexValue()
            self?.save(category: newCategory)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {(UIAlertAction) in
            self.dismiss(animated: true)
        }
        //adding actions to alert
        alert.addAction(cancel)
        alert.addAction(add)
        //presenting alert
        DispatchQueue.main.async {[weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //SUPER CELL FROM SWIPETABLEVC
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       // let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIf, for: indexPath) //as! //SwipeTableViewCell
        //cell.delegate = self
        if let category = arrayOfCategories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.hexColor)
            if let color = cell.backgroundColor {
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
            }
        }
        return cell
    }
    
    //MARK: - TableViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TableView {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.selectedCategory = arrayOfCategories?[indexPath.row]
                destination.navigationItem.title = destination.selectedCategory?.name
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueID, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if let category = arrayOfCategories?[indexPath.row] {
    //            if editingStyle == .delete {
    //                do {
    //                    try realm.write{
    //                        realm.delete(category)
    //                        tableView.reloadData()
    //                    }
    //                }catch{
    //                    print(error.localizedDescription)
    //                }
    //            }
    //        }
    //    }
    
    //MARK: - Data manipulation
    
    func loadCategories() {
        arrayOfCategories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            self.tableView.reloadData()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.arrayOfCategories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(category)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
}


////MARK: - SwipeCell
//extension CategoryTVC: SwipeTableViewCellDelegate {
//    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        
//        guard orientation == .right else { return nil }
//        
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {[weak self] action, indexPath in
//            if let category = self?.arrayOfCategories?[indexPath.row] {
//                do {
//                    try self?.realm.write{
//                        self?.realm.delete(category)
//                        //self?.tableView.reloadData()
//                    }
//                }catch{
//                    print(error.localizedDescription)
//                }
//            }
//        }
//        
//        // customize the action appearance
//        deleteAction.image = UIImage(named: "delete")
//        
//        return [deleteAction]
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }
//    
//}
//
