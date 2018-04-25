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
    var userRef: DatabaseReference!
    var contacts = [ContactCell]() // selected contacts
    // Outlets
    @IBOutlet weak var whereAreYouGoingTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        whereAreYouGoingTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Twilio
    func testTwilio() {
        if let city = whereAreYouGoingTextField.text {
            var userName: String?
            let user = Auth.auth().currentUser
            userRef = Database.database().reference().child("users").child((user?.uid)!)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                userName = value?["name"] as? String ?? ""
                let twilioManager = TwilioManager()
                twilioManager.sendMessage(userName: userName!, city: city)
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("No city added.")
        }
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if ( contacts.count > 0 ) { // have to have some contacts selected
           testTwilio()
        }
        
    }
    

}
