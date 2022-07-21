//
//  Category.swift
//  Todoey-Realm
//
//  Created by Stas Bezhan on 20.07.2022.
//
import RealmSwift
import Foundation

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var hexColor: String?
    let items = List<Item>()
    
}
