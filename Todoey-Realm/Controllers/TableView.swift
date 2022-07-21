//
//  TableView.swift
//  Todoey-Realm
//
//  Created by Stas Bezhan on 20.07.2022.
//
import RealmSwift
import UIKit
import ChameleonFramework

class TableView: SwipeTableVC {
    
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    var todoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let colorHex = selectedCategory?.hexColor {
            guard let navBar = navigationController?.navigationBar else {return}
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hexString: colorHex)
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: appearance.backgroundColor!, returnFlat: true)]
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = navBar.standardAppearance
            
            searchBar.barTintColor = UIColor(hexString: colorHex)
            navBar.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: colorHex)!, returnFlat: true)
            searchBar.searchTextField.backgroundColor = FlatWhite()
        }
    }
    
    //refreshing table view
    @objc func refresh(_ sender: AnyObject) {
        loadItems()
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: - Alert
    //Adding new items to List
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //adding alert for pressing button
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        //action after configuring new item in textfield
        let action = UIAlertAction(title: "Add Item", style: .default) {[weak self] (action) in
            if textField.text != nil && textField.text != "" {
                if let currentCategory = self?.selectedCategory {
                    do {
                        try self?.realm.write{
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
            self?.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { [weak self] (UIAlertAction) in
            self?.dismiss(animated: true)
        }
        
        //adding textfield when alert presented
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            if alertTextField.text != nil && alertTextField.text != "" {
                textField.text = alertTextField.text
            }
        }
        
        //adding an action to alert
        alert.addAction(action)
        alert.addAction(cancelAction)
        DispatchQueue.main.async {[weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - DataManipulation
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: K.cellId, for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let categoryColour = UIColor(hexString: selectedCategory?.hexColor) {
                if let colour = categoryColour.darken(byPercentage: CGFloat(indexPath.row) / CGFloat((todoItems!.count * 5))) {
                    cell.textLabel?.textColor = (ContrastColorOf(backgroundColor: colour, returnFlat: true))
                    cell.backgroundColor = colour
                }
            }
        }else{
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if let item = todoItems?[indexPath.row] {
    //            if editingStyle == .delete {
    //                do {
    //                    try realm.write{
    //                        realm.delete(item)
    //                        tableView.reloadData()
    //                    }
    //                }catch{
    //                    print(error.localizedDescription)
    //                }
    //            }
    //        }
    //    }
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(item)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - SearchBarDelegate:
extension TableView: UISearchBarDelegate {
    //sorting by date
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

