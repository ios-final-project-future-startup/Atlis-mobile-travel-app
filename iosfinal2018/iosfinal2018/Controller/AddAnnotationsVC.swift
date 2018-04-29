//
//  AddAnnotationsVC.swift
//  iosfinal2018
//
//  Created by Denisa Vataksi on 4/29/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import Eureka
import Alamofire
import SwiftyJSON

class AddAnnotationsVC: FormViewController, MKMapViewDelegate,
CLLocationManagerDelegate{
    @IBOutlet weak var addLabel: UILabel!
     var user: User!
    var name: String = ""
    var address: String = ""
    var titleBox: String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        
        form +++ Section("Add a Place")
            
            <<< TextRow(){ row in
                row.title = "Name of Place"
                }.onChange({ (row) in
                    self.name = row.value != nil ? row.value! : ""
                })
            <<< TextRow() { row in
                row.title = "Address/ City"
                }.onChange({ (row) in
                    self.address = row.value != nil ? row.value! : ""
                })
            <<< TextRow() { row in
                row.title = "Recommended by"
                }.onChange({ (row) in
                    self.titleBox = row.value != nil ? row.value! : ""
                })
        <<< ButtonRow() {
            $0.title = "Add"
            }
            .onCellSelection {  cell, row in

            
                //prep data for query to include "+" instead of " "
                let queryName  = self.name.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let queryAddress = self.address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let query = "\(queryName)+\(queryAddress)"
                
                let link = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=AIzaSyBiDY9xYSfMh_VKXZ9cvo4BBItW96aqqig"
                
                //get JSON and save it in database properly
                Alamofire.request(link, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let place = json["results"][0]
                        //print(place)
                        //print("place of place", place["place_id"])
                        //saving to users -> userid -> saved_recommendations -> *placeID -> *
                    
                        
                        print(place["name"].string!)
//                        print(place["rating"].double!)
                        
                        print(Database.database().reference().child("users").child(self.user.uid))
                        
                        
                        
                        
                        let ref = Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").child(place["place_id"].string!)
                        
                        let data = ["name":place["name"].string!,
                                    "address":place["formatted_address"].string!,
                                    "icon":place["icon"].string!,
                                    "lat":place["geometry"]["location"]["lat"].double!,
                                    "lon":place["geometry"]["location"]["lng"].double!,
                                    "rating":place["rating"].double!,
                                    "price_level":place["price_level"] as? Double ?? -1,
                                    "from":self.titleBox] as [String : Any]
                        ref.setValue(data)
                        
                        print("JSON: \(json)")
                    case .failure(let error):
                        print(error)
                    }
                }
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
