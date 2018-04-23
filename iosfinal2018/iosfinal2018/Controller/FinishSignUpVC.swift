//
//  FinishSignUpVC.swift
//  iosfinal2018
//
//  Created by Arjun Madgavkar on 4/22/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Eureka

class FinishSignUpVC: FormViewController {
  var phoneNumber: String!

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpForm()
  }
  
  func setUpForm() {
    NameRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    IntRow.defaultCellSetup = { cell, row in
      cell.textLabel?.font = AvenirNext(size: 17.0)
      cell.textField?.font = AvenirNext(size: 17.0)
    }
    ButtonRow.defaultCellSetup = {cell, row in
      cell.textLabel?.font = AvenirNext(size: 20.0)
      cell.textLabel?.textColor = UIColor(rgb: 0x060A78).withAlphaComponent(1.0)
    }
    form
      // Name
      +++ Section("Create an Account")
      <<< NameRow(){ row in
        row.title = "Name"
        row.tag = "name"
        row.placeholder = "Johnny"
      }
      // Email
      <<< EmailRow(){ row in
        row.title = "Email"
        row.tag = "email"
        row.placeholder = "johnny.appleseed@gmail.com"
      }
      // Button
      +++ Section()
      <<< ButtonRow(){ row in
        row.title = "Finish Sign Up"
        }
        .onCellSelection({ (cell, row) in
          self.finishSignUp()
        })
  }
  
  func finishSignUp() {
    var nameString, emailString: String!
    let formValues = form.values()
    if let name = formValues["name"] {
      nameString = name as! String
    } else {
      showAlert(withTitle: "Missing Name", message: "Please enter a name to continue.")
      return
    }
    if let email = formValues["email"] {
      emailString = email as! String
    } else {
      showAlert(withTitle: "Missing Email", message: "Please enter a valid email to continue.")
      return
    }
    
    // Create user object
    let userData = ["name": nameString, "email": emailString, "phoneNumber": self.phoneNumber] as [String : Any]
    if let user = Auth.auth().currentUser {
      Database.database().reference().child("users").child((user.uid)).updateChildValues(userData) // send to firebase
      self.performSegue(withIdentifier: "goToMainVC", sender: nil)
    }
    
  }
  
  
}
