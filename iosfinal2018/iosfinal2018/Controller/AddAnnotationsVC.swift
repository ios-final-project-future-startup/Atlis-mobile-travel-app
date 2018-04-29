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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Add a Place")
            
            <<< TextRow(){ row in
                row.title = "Name of Place"
            }
            <<< TextRow() { row in
                row.title = "Address/ City"
            }
            <<< TextRow() { row in
                row.title = "Recommended by"
        }
        <<< ButtonRow() {
            $0.title = "Add"
            }
            .onCellSelection {  cell, row in
                let formvalues = self.form.values()
                print(formvalues)
//               self.performSegue(withIdentifier: "MapVC", sender: nil)
        }
    }
    
}
