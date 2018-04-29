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
                
                
                let userID = self.user.uid
                
                let query = "\(self.name)&\(self.address)"
                let link = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=AIzaSyBiDY9xYSfMh_VKXZ9cvo4BBItW96aqqig"
                
                //api request for json
//                Alamofire.request(link).responseJSON { response in
//                    if let result = response.result.value {
//                        let json = JSON(result);
//
//
//                    }
//                }
                
                Alamofire.request(link, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let place = json["results"][0]
                        
                        
                        
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
