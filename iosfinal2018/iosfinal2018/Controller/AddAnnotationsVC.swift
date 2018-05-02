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
                        print(place["types"])
                        if place != JSON.null {
                            let data = ["name":place["name"].string!,
                                        "address":place["formatted_address"].string!,
                                        "icon":place["icon"].string!,
                                        "lat":place["geometry"]["location"]["lat"].double!,
                                        "lon":place["geometry"]["location"]["lng"].double!,
                                        "rating":place["rating"] as? Double ?? -1,
                                        "price_level":place["price_level"] as? Double ?? -1,
                                        "category": self.getCategory(types: place["types"].arrayObject as! [String]),
                                        "from":self.titleBox] as [String : Any]
                            let ref = Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").childByAutoId()
                            ref.setValue(data)
                            print("JSON: \(json)")
                        }
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
    
    func getCategory(types:[String]) -> String{
        let res = "Unkown"
        for type in types{
            if (type == "restaurant" || type == "food" || type == "meal_delivery" || type == "meal_delivery" || type == "meal_takeaway" || type == "supermarket"){
                return "food"
            }
            else if (type == "point_of_interest"){
                return "point_of_interest"
            }
            else if (type == "bar" || type == "night_club"){
                return "night_life"
            }
            else if (type == "bakery"){
                return "bakery"
            }
            else if (type == "cafe"){
                return "cafe"
            }
            else if (type == "clothing_store" || type == "store"||type == "jewelry_store"||type == "furniture_store"||type == "home_goods_store" || type == "shoe_store" || type == "department_store"){
                return "shopping"
            }
            else if (type == "lodging" || type == "lodging"){
                return "accommodation"
            }
        }
        return res
    }
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.doneBtnTapped()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
