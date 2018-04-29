//
//  PlaceAnnotationView.swift
//  iosfinal2018
//
//  Created by Arjun Madgavkar on 4/29/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotationView: MKAnnotationView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil) { self.superview?.bringSubview(toFront: self) }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if !isInside {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside { break } // inside
            }
        }
        return isInside
    }
}
