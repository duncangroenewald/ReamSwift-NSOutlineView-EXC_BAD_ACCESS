//
//  MasterViewController.swift
//  Realm EXC_BAD_ACCESS
//
//  Created by Gianni Chiappetta on 2016-02-22.
//  Copyright © 2016 Demo. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {

    @IBOutlet weak private var sidebarOutlineView: NSOutlineView! {
        didSet {
            sidebarOutlineView.sizeLastColumnToFit()
            sidebarOutlineView.reloadData()
            sidebarOutlineView.floatsGroupRows = false
            sidebarOutlineView.expandItem(nil, expandChildren: true)
        }
    }
    
    let sidebarSections = [
        NSString(string: "Bad"),
        NSString(string: "Good")
    ]
    
    let badItems = store.items.filter("group = 'Bad'")
    let goodItems = store.items.filter("group = 'Good'")
    
//    var badItemsArray: [Item] = []
//    var goodItemsArray: [Item] = []
    
    override func viewDidLoad() {
//        badItemsArray = Array(badItems)
//        goodItemsArray = Array(goodItems)
        
        super.viewDidLoad()
    }
    
    func setupSampleItems() {
        if (store.items.count == 0) {
            store.addItem("Pizza", group: "Good")
            store.addItem("Ice Cream", group: "Good")
            store.addItem("Butts", group: "Good")
            store.addItem("Puppies", group: "Good")
            store.addItem("Spiders", group: "Bad")
            store.addItem("Denim Fedoras", group: "Bad")
            store.addItem("Boiled Eggs", group: "Bad")
            store.addItem("Arthritis", group: "Bad")
        }
    }
    
}

// MARK: NSOutlineViewDataSource
extension MasterViewController: NSOutlineViewDataSource {
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if (item == nil) {
            return sidebarSections.count
        }
        else {
            let itemName = item as! String
            
            switch itemName {
            case "Good":
                return goodItems.count
                
            case "Bad":
                return badItems.count
                
            default:
                return 0
                
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if (outlineView.parentForItem(item) == nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (item == nil) {
            return sidebarSections[index]
        }
        else {
            let itemName = item as! String
            
            switch itemName {
            case "Good":
//                return goodItemsArray[index]
                return goodItems[index]
                
            case "Bad":
//                return badItemsArray[index]
                return badItems[index]
                
            default:
                return 0
                
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        switch item {
        case let title as String:
            let cellView = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            cellView.textField?.stringValue = title
            return cellView
            
        case let anItem as Item:
            let cellView = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            cellView.textField?.stringValue = anItem.name!
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
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        switch item {
        case let title as String:
            return sidebarSections.contains(title)
        case _ as Item:
            return false
        default:
            return false
        }
    }
    
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        return true
    }
}