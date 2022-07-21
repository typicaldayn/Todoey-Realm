//
//  Item.swift
//  Todoey-Realm
//
//  Created by Stas Bezhan on 20.07.2022.
//
import RealmSwift
import Foundation

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
