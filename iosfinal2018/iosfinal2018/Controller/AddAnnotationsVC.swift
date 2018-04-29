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
//               self.performSegue(withIdentifier: "MapVC", sender: nil)
                
                
               
                
                //prep data for query to include "+" instead of " "
                let queryName  = self.name.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let queryAddress = self.address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let query = "\(queryName)&\(queryAddress)"
                
                let link = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=AIzaSyBiDY9xYSfMh_VKXZ9cvo4BBItW96aqqig"
                
                //get JSON and save it in database properly
                Alamofire.request(link, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let place = json["results"][0]
                        
                        //saving to users -> userid -> saved_recommendations -> *placeID -> *
                        let ref = Database.database().reference().child("users").child(self.user.uid).child("savedRecommendations").child(place["placeID"].string!)
                        ref.setValue(["name":place["name"].string!])
                        ref.setValue(["address":place["formatted_address"].string!])
                        ref.setValue(["icon":place["icon"].string!])
                        ref.setValue(["price_level":place["price_level"].string!])
                        ref.setValue(["lat":place["geometry"]["location"]["lat"].string!])
                        ref.setValue(["lon":place["geometry"]["location"]["lng"].string!])
                        ref.setValue(["rating":place["rating"].string!])
                        ref.setValue(["from":self.titleBox])
                        print("JSON: \(json)")
                    case .failure(let error):
                        print(error)
                    }
                }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
