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

class AddAnnotationsVC: FormViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var addLabel: UILabel!
     var user: User!
    var name: String = ""
    var address: String = ""
    var titleBox: String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
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
        form +++ Section("Add a Place")
            <<< TextRow(){ row in
                row.tag = "name"
                row.title = "Name of Place"
                row.placeholder = "Kenka"
                }.onChange({ (row) in
                    self.name = row.value != nil ? row.value! : ""
                })
            <<< TextRow() { row in
                row.tag = "address"
                row.title = "City"
                row.placeholder = "New York City"
                }.onChange({ (row) in
                    self.address = row.value != nil ? row.value! : ""
                })
            <<< TextRow() { row in
                row.tag = "recommended_by"
                row.title = "Recommended by"
                row.placeholder = "Christopher Lawrence"
                }.onChange({ (row) in
                    self.titleBox = row.value != nil ? row.value! : ""
                })
    }
    
    func doneBtnTapped() {
        let values = form.values()
        if let name = values["name"] as? String {
            if let address = values["address"] as? String {
                //prep data for query to include "+" instead of " "
                let queryName  = name.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let queryAddress = address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let query = "\(queryName)+\(queryAddress)"
                let link = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=AIzaSyBiDY9xYSfMh_VKXZ9cvo4BBItW96aqqig"
                //get JSON and save it in database properly
                //saving to users -> userid -> saved_recommendations -> *placeID -> *
                Alamofire.request(link, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let place = json["results"][0]
                        print(place)
                        let data = ["name":place["name"].string!,
                                    "address":place["formatted_address"].string!,
                                    "icon":place["icon"].string!,
                                    "lat":place["geometry"]["location"]["lat"].double!,
                                    "lon":place["geometry"]["location"]["lng"].double!,
                                    "rating":place["rating"].double!,
                                    "price_level":place["price_level"] as? Double ?? -1,
                                    "from":self.titleBox] as [String : Any]
                        Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").updateChildValues(data)
                        print("JSON: \(json)")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                showAlert(withTitle: "Error", message: "City field is empty.")
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            showAlert(withTitle: "Error", message: "Name field is empty.")
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.doneBtnTapped()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
