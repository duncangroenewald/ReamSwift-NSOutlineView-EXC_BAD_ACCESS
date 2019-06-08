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
    @objc dynamic var isDeleted = false   // Instead of deleting the object just mark it for deletion
    
    var items = List<Item>()
    
    
    override static func primaryKey() -> String? {
        return "name"
    }
    var activeItems: Results<Item> {
        return items.filter("isDeleted == false")
    }
    var itemsArray: [Item] {
        return Array(items.filter("isDeleted == false"))
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
    @objc dynamic var isDeleted = false
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

// MARK: Getters
extension Realm {
    var groups: Results<Group> {
        return objects(Group.self).filter("isDeleted == false").sorted(byKeyPath: "name")
    }
    func removeGroup(_ group: Group) {
        do {
            try write {
                group.isDeleted = true
            }
        } catch {
            print("Delete Group action failed: \(error)")
        }
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
                item.isDeleted = true
            }
        } catch {
            print("Delete Item action failed: \(error)")
        }
    }
}

// MARK: Store
let store = try! Realm()
