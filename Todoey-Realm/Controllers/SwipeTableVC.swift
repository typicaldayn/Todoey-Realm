//
//  SwipeTableVC.swift
//  Todoey-Realm
//
//  Created by Stas Bezhan on 21.07.2022.
//
import SwipeCellKit
import UIKit

class SwipeTableVC: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {[weak self] action, indexPath in
            self?.updateModel(at: indexPath)
           // Whats lower is happening in subclasses!!!
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
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    func updateModel(at indexPath: IndexPath) {
        //update data model
        
    }
    
}


