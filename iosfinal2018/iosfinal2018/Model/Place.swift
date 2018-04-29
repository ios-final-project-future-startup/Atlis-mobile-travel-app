//
//  Place.swift
//  iosfinal2018
//
//  Created by Denisa Vataksi on 4/24/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import MapKit

class Place: NSObject {
    var coordinate: CLLocationCoordinate2D
    var title: String? //name of place
    var address: String?
    var subtitle: String? //will link to a friend and be the subtitle of the annotation
    var icon: String?
    var name: String?
    var price_level: Double?
    var rating: Double?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
extension Place: MKAnnotation { }
