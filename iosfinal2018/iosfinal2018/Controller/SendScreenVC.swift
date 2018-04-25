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
    var contacts = [ContactCell]() // selected contacts
    var selectedContacts = [Contact]()
    var phoneNumbers = [String]()
    // Outlets
    @IBOutlet weak var whereAreYouGoingTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    func setUpViewController() {
        user = Auth.auth().currentUser
        whereAreYouGoingTextField.delegate = self
    }
    
    func formatContactStrings() {
        for contact in selectedContacts {
            let contactNumber = contact.number
            let newNumber = contactNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
            var finalNumber = newNumber.joined(separator: "")
            if finalNumber.hasPrefix("1") { finalNumber.remove(at: finalNumber.startIndex) } // get rid of the 1 at beginning of #
            finalNumber = "+1" + finalNumber
            phoneNumbers.append(finalNumber) // add to array of strings that we give to Twilio
        }
    }
    
    func saveOutgoingRequestsToDatabase(phoneNumbers: [String]) {
        let ref = Database.database().reference().child("outgoing_requests")
        for phoneNumber in phoneNumbers {
            ref.updateChildValues([phoneNumber: user.uid]) // add to the database
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
                let value = snapshot.value as? NSDictionary
                userName = value?["name"] as? String ?? "" // get user value
                let twilioManager = TwilioManager()
                twilioManager.sendMessage(userName: userName!, city: city, phoneNumbers: self.phoneNumbers)
                self.saveOutgoingRequestsToDatabase(phoneNumbers: self.phoneNumbers) // save outgoing requests to database
            }) { (error) in
                print(error.localizedDescription)
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
