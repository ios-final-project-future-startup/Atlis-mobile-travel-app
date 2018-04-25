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
    var userRef: DatabaseReference!
    

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
      
      testTwilio()
      
    }
  
  func testTwilio() {
    var userName: String?
    let user = Auth.auth().currentUser
    userRef = Database.database().reference().child("users").child((user?.uid)!)
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
      let value = snapshot.value as? NSDictionary
      userName = value?["name"] as? String ?? ""
      let twilioManager = TwilioManager()
      twilioManager.sendMessage(userName: userName!, city: "Tokyo")
    }) { (error) in
      print(error.localizedDescription)
    }
    
    
    
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

    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        var contactsSelected = [ContactCell]()
        for cell in contactsTableView.visibleCells as! [ContactCell]{
            if(cell.isSelected){
                contactsSelected.append(cell)
            }
        }
        
        performSegue(withIdentifier: "SendScreenVC", sender: contactsSelected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? SendScreenVC{
            if let chosen = sender as! [ContactCell]?{
                destination.contacts = chosen
            }
        }
    }
    
    

}
