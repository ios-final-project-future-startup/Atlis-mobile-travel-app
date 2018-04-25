//
//  TwilioManager.swift
//  iosfinal2018
//
//  Created by Arjun Madgavkar on 4/23/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Alamofire

class TwilioManager {
    
    init() {} // blank init function that creates type of TwilioManager
  
    func sendMessage(userName: String, city: String, phoneNumbers: [String]) {
        let baseURL = "https://us-central1-ios-finalproject-2018.cloudfunctions.net/sendMessage"
        let headers: HTTPHeaders = ["Content-Type": "application/json"] // tell server that we are sending JSON
        let parameters: [String : Any] = [
            "userName" : userName,
            "city" : city,
            "phoneNumbers" : phoneNumbers
        ]
        Alamofire.request(baseURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error { print(error.localizedDescription) }
            else { print(response.description) }
        }
  }
  
  
  
}
