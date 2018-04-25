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
//  let userID: String
//  let userName: String
//  let city: String
    
    init() {} // blank init function that creates type of TwilioManager
  /*
  init(userID: String, userName: String, city: String) { // blank init function that creates type of TwilioManager
    self.userID = userID
    self.userName = userName
    self.city = city
  }
 */
  
    func sendMessage(userName: String, city: String) {
        let baseURL = "https://us-central1-ios-finalproject-2018.cloudfunctions.net/sendMessage"
//    let http = "\(base)\(self.getUserName())&\(self.getCity())"
//    print(http)
//    Alamofire.request(http).response { (response) in
//      print(response)
//    }
        let headers: HTTPHeaders = ["Content-Type": "application/json"] // tell server that we are sending JSON
        let parameters: [String : String] = ["userName" : userName, "city" : city]
        Alamofire.request(baseURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                print(error.localizedDescription)
            } else {
                print(response.description)
            }
        }
  }
  
//  func getUserName() -> String {
//    return "username=\(self.userName)"
//  }
//
//  func getUserID() -> String {
//    return "userid=\(self.userID)"
//  }
//
//  func getCity() -> String {
//    return "city=\(self.city)"
//  }
//
  
  
  
}
