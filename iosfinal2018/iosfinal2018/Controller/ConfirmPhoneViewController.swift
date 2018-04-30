//
//  ConfirmPhoneViewController.swift
//  iosfinal2018
//
//  Created by Arjun Madgavkar on 4/16/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConfirmPhoneViewController: UIViewController {
  // Variables
  var phoneNumber : String?
  // Outlets
  @IBOutlet weak var confirmationCodeTextfield: UITextField!
  
  override func viewDidLoad() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)

    super.viewDidLoad()
  }
  
  func userSignIn(credential: AuthCredential) {
    Auth.auth().signIn(with: credential) { (user, error) in
      if let error = error {
        self.showAlert(withTitle: "Error", message: error.localizedDescription)
        return
      }
      // User is signed in
      self.performSegue(withIdentifier: "goToFinishSignUpVC", sender: nil)
    }
  }
  
  @IBAction func confirmBtnTapped(_ sender: Any) {
    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") // value is stored to disk
    if let code = confirmationCodeTextfield.text {
      let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationID!,
        verificationCode: code)
      userSignIn(credential: credential)
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Send data
    if segue.identifier == "goToFinishSignUpVC" {
      let destVC = segue.destination as! FinishSignUpVC
      destVC.phoneNumber = phoneNumber
    }
  }
  

}
