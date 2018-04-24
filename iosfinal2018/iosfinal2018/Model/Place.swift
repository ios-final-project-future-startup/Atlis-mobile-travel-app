//
//  Place.swift
//  iosfinal2018
//
//  Created by Denisa Vataksi on 4/24/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import MapKit

@objc class Place: NSObject {
    var coordinate: CLLocationCoordinate2D
    var friend: String!
    var title: String?
    var subtitle: String?
    var recomendation: String!
    var address: String?
    var image: UIImage?
    
    init(title: String?, recomendation: String!, coordinate: CLLocationCoordinate2D,
         friend: String!, address: String?, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.recomendation = recomendation
        self.friend = friend
        self.address = address
    }
    
    static func getPlaces() -> [Place] {
        //guard let path =
        
        var places = [Place]()
        
        for item in array {
           
        }
        
        return places as [Place]
    }
}

extension Place: MKAnnotation { }
