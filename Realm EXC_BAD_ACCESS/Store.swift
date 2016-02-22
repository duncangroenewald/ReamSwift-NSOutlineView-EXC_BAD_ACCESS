//
//  Store.swift
//  Realm EXC_BAD_ACCESS
//
//  Created by Gianni Chiappetta on 2016-02-22.
//  Copyright © 2016 Demo. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    dynamic var name: String?
    dynamic var group: String?
}

// MARK: Getters
extension Realm {
    var items: Results<Item> {
        return objects(Item.self)
    }
}

// MARK: Actions
extension Realm {
    func addItem(name: String, group: String) {
        do {
            try write {
                let item = Item()
                item.name = name
                item.group = group
                add(item)
            }
        } catch {
            print("Add Item action failed: \(error)")
        }
    }
    
    func removeItem(item: Item) {
        do {
            try write {
                delete(item)
            }
        } catch {
            print("Delete Item action failed: \(error)")
        }
    }
}

// MARK: Store
let store = try! Realm()