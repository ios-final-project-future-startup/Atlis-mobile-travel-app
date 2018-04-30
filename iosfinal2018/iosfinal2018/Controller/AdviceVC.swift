//
//  AdviceVC.swift
//  iosfinal2018
//
//  Created by Zachary Kimelheim on 4/10/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import SwiftMultiSelect

class AdviceVC: UIViewController  {
    
    var contactStore = CNContactStore()
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    var items:[SwiftMultiSelectItem] = [SwiftMultiSelectItem]()
    var selectedItems:[SwiftMultiSelectItem] = [SwiftMultiSelectItem]()
    var initialValues:[SwiftMultiSelectItem] = [SwiftMultiSelectItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
    }
    
    func setUpVC() {
        // SwiftMultiSelect
        SwiftMultiSelect.delegate = self
        SwiftMultiSelect.dataSource = self
        SwiftMultiSelect.dataSourceType = .phone
        // Nav Bar
        self.title = "Advice"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SendScreenVC {
            destination.selectedContacts = self.selectedContacts
        }
    }
    
    @IBAction func selectContactsBtnTapped(_ sender: Any) {
        SwiftMultiSelect.Show(to: self)
    }
    
}

//MARK: - SwiftMultiSelectDelegate
extension AdviceVC: SwiftMultiSelectDelegate {
    func userDidSearch(searchString: String) {
        if searchString == "" {
            selectedItems = items
        } else {
            selectedItems = items.filter({$0.title.lowercased().contains(searchString.lowercased()) || ($0.description != nil && $0.description!.lowercased().contains(searchString.lowercased())) })
        }
    }
    
    func numberOfItemsInSwiftMultiSelect() -> Int {
        return selectedItems.count
    }
    
    func swiftMultiSelect(didUnselectItem item: SwiftMultiSelectItem) {
        print("row: \(item.title) has been deselected!")
    }
    
    func swiftMultiSelect(didSelectItem item: SwiftMultiSelectItem) {
        print("item: \(item.title) has been selected!")
    }
    
    func didCloseSwiftMultiSelect() {
        //badge.isHidden = true
        //badge.text = ""
    }
    
    func swiftMultiSelect(itemAtRow row: Int) -> SwiftMultiSelectItem {
        return selectedItems[row]
    }
    
    func swiftMultiSelect(didSelectItems items: [SwiftMultiSelectItem]) {
        initialValues   = items
        if items.count > 0 {
            for item in items {
                if let contact = item.userInfo as? CNContact {
                    let name = contact.givenName
                    let familyname = contact.familyName
                    let number = contact.phoneNumbers.first?.value.stringValue
                    if ( name != "" && number != nil ) {
                        let contactToAppend = Contact(first: name, last: familyname, number: number!)
                        self.selectedContacts.append(contactToAppend)
                    }
                }
            }
            self.performSegue(withIdentifier: "sendScreenVC", sender: nil)
        }
    }
}

extension AdviceVC: SwiftMultiSelectDataSource {
    
}












