//
//  AdviceVC.swift
//  iosfinal2018
//
//  Created by Zachary Kimelheim on 4/10/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Contacts

class AdviceVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var contactStore = CNContactStore()
    var contacts = [Contact]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        contactStore.requestAccess(for: .contacts, completionHandler: { (success, error) in
            if(success){
                print("Authorization successful")
            }
        })
        
       fetchContacts()
       
        //self.contactsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")


    }

    func fetchContacts(){
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: key)
        
        try! contactStore.enumerateContacts(with: request, usingBlock: { (contact, stoppablePointer) in
            let name = contact.givenName
            let familyname = contact.familyName
            let number = contact.phoneNumbers.first?.value.stringValue
            
            let contactToAppend = Contact(first: name, last: familyname, number: number!)
            self.contacts.append(contactToAppend)
        })
        contactsTableView.reloadData()
      
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell{
            let contact = contacts[indexPath.row]
            cell.nameLbl.text = contact.first + " " + contact.last
            return cell
        }
        else {
            return UITableViewCell()
        }
        
        
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        let contactToDisplay = contacts[indexPath.row]
//        cell.textLabel?.text = contactToDisplay.first + " " + contactToDisplay.last
//        cell.detailTextLabel?.text = contactToDisplay.number
//        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = contactsTableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark

    }
    

}
