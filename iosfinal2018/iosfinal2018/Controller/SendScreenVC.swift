//
//  SendScreenVC.swift
//  iosfinal2018
//
//  Created by Zachary Kimelheim on 4/10/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Firebase


class SendScreenVC: UIViewController, UITextFieldDelegate {
    // Properties
    var user: User!
    var selectedContacts = [Contact]()
    var phoneNumbers = [String]()
    var contacts = [String:String]()
    
    // Outlets
    @IBOutlet weak var whereAreYouGoingTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        resetArrays()
    }
    
    func setUpViewController() {
        user = Auth.auth().currentUser
        whereAreYouGoingTextField.delegate = self
    }
    
    func resetArrays() {
        self.phoneNumbers.removeAll()
        self.contacts.removeAll()
    }
    
    func formatContactStrings() {
        for contact in selectedContacts {
            // Phone Number
            let contactNumber = contact.number
            let newNumber = contactNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
            var finalNumber = newNumber.joined(separator: "")
            if finalNumber.hasPrefix("1") { finalNumber.remove(at: finalNumber.startIndex) } // get rid of the 1 at beginning of #
            finalNumber = "+1" + finalNumber
            // Name
            let name = contact.first + " " + contact.last
            // Add data
            self.phoneNumbers.append(finalNumber) // we use the array for twilio
            contacts[name] = finalNumber // we use the dictionary for saving to firebase
        }
    }
    
    // MARK: Firebase
    func saveToDatabase(contacts: [String:String]) {
        let outgoingRef = Database.database().reference().child("outgoing_requests")
        let requestingToRef = Database.database().reference().child("users").child(user.uid).child("requesting_to")
        for (key, value) in contacts {
            let name = key
            let phoneNumber = value
            outgoingRef.updateChildValues([phoneNumber: user.uid]) // save outgoing request
            requestingToRef.updateChildValues([phoneNumber:name]) // save requesting value
        }
    }
    
    // MARK: TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Twilio
    func sendTwilioMessage() {
        if let city = whereAreYouGoingTextField.text {
            var userName: String?
            let userRef = Database.database().reference().child("users").child(user.uid)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Firebase
                let value = snapshot.value as? NSDictionary
                userName = value?["name"] as? String ?? "" // get user value
                let twilioManager = TwilioManager()
                twilioManager.sendMessage(userName: userName!, city: city, phoneNumbers: self.phoneNumbers)
                self.saveToDatabase(contacts: self.contacts) // save outgoing requests to database
                // Alert + Unwind
                let alert = UIAlertController(title: "Success!", message: "Your requests have been sent to your friends, we'll let you know when it's automatically updated on your map!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (_)in
                    self.performSegue(withIdentifier: "unwindToMap", sender: self) // unwind segue
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }) { (error) in
                self.showAlert(withTitle: "Error", message: error.localizedDescription)
            }
        } else {
            print("No city added.")
        }
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if ( selectedContacts.count > 0 ) { // have to have some contacts selected
            formatContactStrings() // make sure contacts are formatted
            sendTwilioMessage() // send twilio message with contacts
        }
    }
}
