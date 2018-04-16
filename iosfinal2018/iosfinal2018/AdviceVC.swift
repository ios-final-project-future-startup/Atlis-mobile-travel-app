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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let contactToDisplay = contacts[indexPath.row]
        cell.textLabel?.text = contactToDisplay.first + " " + contactToDisplay.last
        cell.detailTextLabel?.text = contactToDisplay.number
        return cell
    }
    
    
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
        for contact in contacts{
            print(contact.first + " " + contact.last)
        }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
