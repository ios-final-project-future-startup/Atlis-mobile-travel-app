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
    var userid: String! //will link to a friend and be the subtitle of the annotation
    var title: String?
    var subtitle: String?
    var address: String?
    var image: UIImage?
    
    init(title: String?, coordinate: CLLocationCoordinate2D,
         userid: String!) {
        self.title = title
        self.coordinate = coordinate
        self.userid = userid
    }
    
//    static func getPlaces() -> [Place] {
//        //guard let path =
//        
//        var places = [Place]()
//        
////        for item in array {
////           
////        }
//        
//        return places as [Place]
//    }
}

extension Place: MKAnnotation { }
