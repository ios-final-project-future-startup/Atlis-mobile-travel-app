//
//  ViewController.swift
//  iosfinal2018
//
//  Created by Zachary Kimelheim on 4/10/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit

import Firebase
import GoogleMaps
import GooglePlaces
import MapKit


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var map: MKMapView!

    
    fileprivate var annotation: MKAnnotation!
    fileprivate var locationManager: CLLocationManager!

    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Configure Firebase app
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        locationManager?.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        

//
        map.delegate = self
        map.mapType = .hybrid
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        if self.map.annotations.count != 0 {
            annotation = self.map.annotations[0]
            self.map.removeAnnotation(annotation)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        map.addAnnotation(pointAnnotation)
    }

    
    
    


}

