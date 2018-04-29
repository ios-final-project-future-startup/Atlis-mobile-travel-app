//
//  LoginViewController.swift
//  iosfinal2018
//
//  Created by Arjun Madgavkar on 4/16/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
  var phoneNumber: String?
  
  @IBOutlet weak var phoneNumberTextfield: UITextField!
  
  override func viewDidLoad() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    super.viewDidLoad()
    
  }
  
  @IBAction func getConfirmationBtnTapped(_ sender: Any) {
    if ( phoneNumberTextfield.text != nil && (phoneNumberTextfield.text?.count)! == 10) {
      phoneNumber = "+1" + phoneNumberTextfield.text!
      PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { (verificationID, error) in
        if let error = error {
          self.showAlert(withTitle: "Error", message: error.localizedDescription)
          return
        }
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID") // Save to disk
        self.performSegue(withIdentifier: "goToConfirmVC", sender: nil)
      }
    } else {
      self.showAlert(withTitle: "Invalid Phone Number", message: "Please check to make sure that the phone number provided is correct.")
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destVC = segue.destination as! ConfirmPhoneViewController
    destVC.phoneNumber = phoneNumber
  }
  
  
  

}
