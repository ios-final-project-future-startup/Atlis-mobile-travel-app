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

class AdviceVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    var contactStore = CNContactStore()
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    

    override func viewDidLoad() {
      super.viewDidLoad()
      contactsTableView.delegate = self
      contactsTableView.dataSource = self
      
      contactStore.requestAccess(for: .contacts, completionHandler: { (success, error) in
          if ( success ) {
            print("Authorization successful")
            self.fetchContacts()
          }
      })
    
      contactsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "A")
      
      
    }

    func fetchContacts(){
      let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
      
      let request = CNContactFetchRequest(keysToFetch: key)
      
      try! contactStore.enumerateContacts(with: request, usingBlock: { (contact, stoppablePointer) in
        let name = contact.givenName
        let familyname = contact.familyName
        let number = contact.phoneNumbers.first?.value.stringValue
        if ( name != "" && number != nil ) {
          let contactToAppend = Contact(first: name, last: familyname, number: number!)
          self.contacts.append(contactToAppend)
        }
      })
      DispatchQueue.main.async { self.contactsTableView.reloadData() } // execute this once block finishes
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell{
            let contact = contacts[indexPath.row]
            cell.nameLbl.text = contact.first + " " + contact.last
            cell.phoneNumberLbl.text = contact.number
            return cell
        }
        else {
            return UITableViewCell()
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = contactsTableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        
        let contact = contacts[indexPath.row] // use the value of the indexPath to get contact
        selectedContacts.append(contact)

    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        //var contactsSelected = [ContactCell]()
//        for cell in contactsTableView.visibleCells as! [ContactCell]{
//            if(cell.isSelected){
//                contactsSelected.append(cell)
//            }
//        }
        self.performSegue(withIdentifier: "SendScreenVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SendScreenVC {
            destination.selectedContacts = self.selectedContacts
//            if let chosen = sender as! [ContactCell]?{
//                destination.contacts = chosen
//            }
        }
    }
    
    

}
