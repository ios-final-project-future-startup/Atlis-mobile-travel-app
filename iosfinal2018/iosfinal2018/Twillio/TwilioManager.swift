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
  let userID: String
  let userName: String
  let city: String
  
  init(userID: String, userName: String, city: String) { // blank init function that creates type of TwilioManager
    self.userID = userID
    self.userName = userName
    self.city = city
  }
  
  func sendMessage() {
    let baseURL = "https://us-central1-ios-finalproject-2018.cloudfunctions.net/sendMessage"
//    let http = "\(base)\(self.getUserName())&\(self.getCity())"
//    print(http)
//    Alamofire.request(http).response { (response) in
//      print(response)
//    }
    //let headers: HTTPHeaders = ["Content-Type": "application/json"] // tell server that we are sending JSON
    let parameters: [String : String] = ["username" : "arjun", "city" : "tokyo"]
    Alamofire.request(baseURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
      .responseString { response in
        print("Success")
    }
    
  }
  
  func getUserName() -> String {
    return "username=\(self.userName)"
  }
  
  func getUserID() -> String {
    return "userid=\(self.userID)"
  }
  
  func getCity() -> String {
    return "city=\(self.city)"
  }
  
  
  
  
}
