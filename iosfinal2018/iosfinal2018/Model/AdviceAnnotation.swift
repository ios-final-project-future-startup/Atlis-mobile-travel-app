//
//  AdviceAnnotation.swift
//  iosfinal2018
//
//  Created by Denisa Vataksi on 4/24/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import MapKit

class AdviceAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var friend: String!
    var title: String?
    var recomendation: String!
    var address: String?
    var image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, friend: String, recomendation: String) {
        self.coordinate = coordinate
        self.friend = friend
        self.recomendation = recomendation
    }
}
