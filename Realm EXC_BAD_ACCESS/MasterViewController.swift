//
//  MasterViewController.swift
//  Realm EXC_BAD_ACCESS
//
//  Created by Gianni Chiappetta on 2016-02-22.
//  Copyright © 2016 Demo. All rights reserved.
//

import Cocoa

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
    
    override func viewDidLoad() {
        
        //store.deleteAllItems()
        
        setupSampleItems()
        
        
        super.viewDidLoad()
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        
        let row = self.outlineView.selectedRow
        
        guard row > -1 else {
            return
        }
        
        if let item = self.outlineView.item(atRow: row) as? Item, let realm = item.realm {
            
            realm.beginWrite()
            
            item.isDeleted = true
//            realm.delete(item)
            
            do {
                try realm.commitWrite()
                
                self.outlineView.reloadData()
                
            } catch {
                print("Error!!")
            }
            
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
//                return group.items.count
//                return group.itemsArray.count
                return group.activeItems.count
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
                
//                return group.items[index]
//                return group.itemsArray[index]
                return group.activeItems[index]
                
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
