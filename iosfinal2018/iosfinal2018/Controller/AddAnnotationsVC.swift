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
                print(self.name)
//               self.performSegue(withIdentifier: "MapVC", sender: nil)
        }
    }
    
}
