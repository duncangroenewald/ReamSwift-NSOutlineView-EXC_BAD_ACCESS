//
//  Store.swift
//  Realm EXC_BAD_ACCESS
//
//  Created by Gianni Chiappetta on 2016-02-22.
//  Copyright © 2016 Demo. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {
    @objc dynamic var name: String?
    
    var items = List<Item>()
    
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    var itemsArray: [Item] {
        return Array(items)
    }
    func addItem(_ name: String)->Bool{
        do {
            realm!.beginWrite()
            let newItem = realm!.create(Item.self, value: ["name": name, "group": self], update: .modified)
            items.append(newItem)
            
            try realm!.commitWrite()
            return true
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
}
class Item: Object {
    @objc dynamic var name: String?
    @objc dynamic var group: Group?
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

// MARK: Getters
extension Realm {
    var groups: Results<Group> {
        return objects(Group.self).sorted(byKeyPath: "name")
    }
    func deleteAllItems() {
        beginWrite()
        deleteAll()
        do {
            try commitWrite()
        } catch {
            
        }
    }
}

// MARK: Actions
extension Realm {
    func addGroup(_ name: String)->Group?{
        do {
            let group = Group()
            group.name = name
            try write {
                add(group)
            }
            return group
        } catch {
            print("Add Group action failed: \(error)")
            return nil
        }
    }
    
    func removeItem(_ item: Item) {
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
