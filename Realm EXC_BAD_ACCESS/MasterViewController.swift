//
//  MasterViewController.swift
//  Realm EXC_BAD_ACCESS
//
//  Created by Gianni Chiappetta on 2016-02-22.
//  Copyright © 2016 Demo. All rights reserved.
//

import Cocoa
import RealmSwift

class MasterViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak private var sidebarOutlineView: NSOutlineView! {
        didSet {
            sidebarOutlineView.sizeLastColumnToFit()
            sidebarOutlineView.reloadData()
            sidebarOutlineView.floatsGroupRows = false
            sidebarOutlineView.expandItem(nil, expandChildren: true)
        }
    }
    
    let sidebarSections = store.groups
    
    var notificationToken: NotificationToken?
    
    var childNotificationTokens = [Group: NotificationToken]()
    
    var selectedItem: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up notifications for changes to the store.groups list (do we get notified about child updates??)
//        notificationToken = sidebarSections.observe {changes in
//            self.applyGroupChanges(changes: changes)
//        }
//
//        for group in sidebarSections {
//
//            let notification = group.activeItems.observe {changes in
//                self.applyChanges(group: group, changes: changes)
//            }
//            childNotificationTokens[group] = notification
//
//        }
        
                store.deleteAllItems()
        
        setupSampleItems()
        
        self.outlineView.reloadData()
    }
    deinit {
        notificationToken?.invalidate()
        for (_, token) in childNotificationTokens {
            token.invalidate()
        }
    }
    @IBAction func deleteItem(_ sender: Any) {
        
        let row = self.outlineView.selectedRow
        
        guard row > -1 else {
            return
        }
        
        if let item = self.outlineView.item(atRow: row) as? Item, let parentObject = item.group, let realm = item.realm {
            
            print("Deleting \(item.name)")
            
            let itemRow = self.outlineView.childIndex(forItem: item)
            
            realm.beginWrite()
            
            self.outlineView?.removeItems(at: IndexSet(integer: itemRow), inParent: parentObject, withAnimation: NSTableView.AnimationOptions.slideUp)
            
//            item.isDeleted = true
            realm.delete(item)
            
            do {
                try realm.commitWrite()
                
            } catch {
                print("Error!!")
                self.outlineView.reloadData()
            }
        } else if let item = self.outlineView.item(atRow: row) as? Group, let realm = item.realm {
            
            print("Deleting \(item.name)")
            
             let itemRow = self.outlineView.childIndex(forItem: item)
            
            realm.beginWrite()
            
            self.outlineView?.removeItems(at: IndexSet(integer: itemRow), inParent: nil, withAnimation: NSTableView.AnimationOptions.slideUp)
            
//            item.isDeleted = true
            realm.delete(item)
            
            do {
                try realm.commitWrite()
                
                // Remove the notification
                // self.childNotificationTokens[item]?.invalidate()
                // self.childNotificationTokens[item] = nil
                
            } catch {
                print("Error!!")
                self.outlineView.reloadData()
            }
        }
    }
    /// Add an item to the current 'parent'
    @IBAction func addItem(_ sender: Any) {
        
        let row = self.outlineView.selectedRow
        
        guard row > -1 else {
            return
        }
        if let item = self.outlineView.item(atRow: row) as? Item, let parent = item.group {
            
            
            if let item = parent.addItem("Item #\(parent.items.count)"), let index = parent.activeItems.index(of: item) {
                
                self.outlineView?.insertItems(at: IndexSet(integer: index), inParent: parent, withAnimation: NSTableView.AnimationOptions.slideDown)
                
                let newItemRow = self.outlineView.row(forItem: item)
                self.outlineView?.selectRowIndexes(IndexSet(integer: newItemRow), byExtendingSelection: false)
                self.outlineView?.scrollRowToVisible(newItemRow)
                
            }
        } else if let _ = self.outlineView.item(atRow: row) as? Group {
            
            let groupCount = store.groups.count
            if let item = store.addGroup("Group #\(groupCount)"), let index = sidebarSections.index(of: item) {
                
                self.outlineView?.insertItems(at: IndexSet(integer: index), inParent: nil, withAnimation: NSTableView.AnimationOptions.slideDown)
                
                let newItemRow = self.outlineView.row(forItem: item)
                self.outlineView?.selectRowIndexes(IndexSet(integer: newItemRow), byExtendingSelection: false)
                self.outlineView?.scrollRowToVisible(newItemRow)
                
            }
        }
    }
    @IBAction func updates(_ sender: Any) {
        
        // perform some updates in the background
        // and what them appear in the outlineView
        DispatchQueue.global().async {
            
            let realm = try! Realm()
            
            for _ in 1...5 {
                
                let next = realm.allGroups.count + 1
                
                // Add a group
                if let group = realm.addGroup("Group \(next)") {
                    
                    let _ = group.addItem("James")
                    let _ = group.addItem("Peter")
                    let _ = group.addItem("Pumpkin")
                    let _ = group.addItem("Eater")
                    
                    if let name = group.name {
                        Thread.sleep(forTimeInterval: 2)
                        DispatchQueue.main.async {
                            self.expandGroup(name: name)
                        }
                    }
                }
            }
//            let groups = realm.objects(Group.self)
//
//            for group in groups {
//
//                if group.items.count > 2 {
//                    let item = group.items[1]
//
//                    do {
//                        try realm.write {
//                            item.isDeleted = true
//                        }
//                    } catch {
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//            }
        }
    }
    /// Pass Id so we can access from another thread
    func expandGroup(name: String){
        if let group = store.groups.first(where: {group in group.name == name}) {
            self.outlineView.expandItem(group, expandChildren: true)
        }
    }
    func setupSampleItems() {
        
        print("store.group.count: \(store.groups.count )")
        
        if (store.groups.count == 0) {
            if let groupBad = store.addGroup("Bad"), let groupGood = store.addGroup("Good") {
                let _ = groupGood.addItem("Pizza")
                let _ = groupGood.addItem("Ice Cream")
                let _ = groupGood.addItem("Butts")
                let _ = groupGood.addItem("Puppies")
                let _ = groupBad.addItem("Spiders")
                let _ = groupBad.addItem("Denim Fedoras")
                let _ = groupBad.addItem("Boiled Eggs")
                let _ = groupBad.addItem("Arthritis")
            } else {
                print("Error creating groups and items")
            }
        }
        
        print("store.group.count: \(store.groups.count )")
    }
    
}

// MARK: NSOutlineViewDataSource
extension MasterViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if (item == nil) {
            return sidebarSections.count
        }
        else {
            if let group = item as? Group {
                return group.items.count
                //                return group.itemsArray.count
//                return group.activeItems.count
            }
            return 0
        }
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if (outlineView.parent(forItem: item) == nil) {
            return true
        }
        else {
            return false
        }
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            return sidebarSections[index]
        }
        else {
            if let group = item as? Group {
                
                return group.items[index]
                //                return group.itemsArray[index]
//                return group.activeItems[index]
                
            }
            return 0
        }
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        switch item {
        case let group as Group:
            let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as! NSTableCellView
            cellView.textField?.stringValue = group.name ?? "-"
            return cellView
            
        case let anItem as Item:
            let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as! NSTableCellView
            cellView.textField?.stringValue = anItem.name ?? "-"
            return cellView
            
        default:
            dump(item)
            print("WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            return nil
        }
    }
}

// MARK: NSOutlineViewDelegate
extension MasterViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        switch item {
        case _ as Group:
            return true
        case _ as Item:
            return false
        default:
            return false
        }
    }
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }
}

extension MasterViewController {
    func applyGroupChanges<T>(changes: RealmCollectionChange<T>) {
        switch changes {
        case .initial: self.outlineView?.reloadData()
        case .update(_ , let deletions, let insertions, let updates):
            
            let fromRow = { (row: Int) in
                return row }
            print(" ")
            print("group deletions: \(deletions)")
            print("group insertions: \(insertions)")
            print("group updates: \(updates)")
            // Translate the updates to rows for the items
            let updateRows = updates.map({(row: Int) -> Int in
                
                let group = self.sidebarSections[row]
                let groupRow = self.outlineView.row(forItem: group)
                return groupRow
                
            })
            
            self.outlineView?.beginUpdates()
            self.outlineView?.removeItems(at: IndexSet(deletions.map(fromRow)), inParent: nil, withAnimation: NSTableView.AnimationOptions.slideUp)
            self.outlineView?.insertItems(at: IndexSet(insertions.map(fromRow)), inParent: nil, withAnimation: NSTableView.AnimationOptions.slideDown)
            self.outlineView?.reloadData(forRowIndexes: IndexSet(updateRows), columnIndexes: IndexSet(integer: 0))
            self.outlineView?.endUpdates()
            
            for index in insertions {
                let group = self.sidebarSections[index]
                self.childNotificationTokens[group] = group.activeItems.observe {changes in
                    self.applyChanges(group: group, changes: changes)
                }
            }
            
            
            // If inserted item then select it
            if insertions.count > 0 {
                let row = insertions[0]
                self.outlineView?.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                self.outlineView?.scrollRowToVisible(row)
            }
            
        case .error(let error): fatalError("\(error)")
        }
    }
    func applyChanges<T>(group: Group, changes: RealmCollectionChange<T>) {
        
        let parent = group
        let parentRow = self.outlineView.row(forItem: parent)
        
        switch changes {
        case .initial: self.outlineView?.reloadData()
        case .update(_ , let deletions, let insertions, let updates):
            
            let fromRow = { (row: Int) in
                return row }
            
            print("item deletions: \(deletions)")
            print("item insertions: \(insertions)")
            print("item updates: \(updates)")
            self.outlineView?.beginUpdates()
            self.outlineView?.removeItems(at: IndexSet(deletions.map(fromRow)), inParent: parent, withAnimation: NSTableView.AnimationOptions.slideUp)
            self.outlineView?.insertItems(at: IndexSet(insertions.map(fromRow)), inParent: parent, withAnimation: NSTableView.AnimationOptions.slideDown)
            self.outlineView?.reloadData(forRowIndexes: IndexSet(updates.map({row in return row + parentRow})), columnIndexes: IndexSet(integer: 0))
            self.outlineView?.endUpdates()
            
            // If inserted item then select it
            if insertions.count > 0 {
                let item = group.activeItems[insertions[0]]
                let row = self.outlineView.row(forItem: item)
                self.outlineView?.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                self.outlineView?.scrollRowToVisible(row)
            }
            
        case .error(let error): fatalError("\(error)")
        }
    }
}
