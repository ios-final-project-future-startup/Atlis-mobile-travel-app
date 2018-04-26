
//
//  ViewController.swift
//  iosfinal2018
//
//  Created by Zachary Kimelheim on 4/10/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//{
//    "outgoing_requests" : {
//        "+12158023985" : "9teq2RwlKuZrYMAbIVMzZitvSNY2",
//        "+13476456317" : "9teq2RwlKuZrYMAbIVMzZitvSNY2",
//        "+15105060380" : "9teq2RwlKuZrYMAbIVMzZitvSNY2",
//        "+15107018459" : "9teq2RwlKuZrYMAbIVMzZitvSNY2",
//        "+16155121301" : "9teq2RwlKuZrYMAbIVMzZitvSNY2",
//        "+16785253741" : "9teq2RwlKuZrYMAbIVMzZitvSNY2"
//    },
//    "users" : {
//        "9teq2RwlKuZrYMAbIVMzZitvSNY2" : {
//            "email" : "arjun.madgavkar@gmail.com",
//            "full_name" : "Arjun Madgavkar",
//            "number" : "+19739862294",
//            "requesting_to" : {
//                "+12158023985" : "Zack Kimelheim"
//            },
//            "saved_recommendations" : {
//                "0ed4fa342e8c59111d07d80b81f5c08cd6b84934" : {
//                    "address" : "7 Carmine St, New York, NY 10014, USA",
//                    "from" : "Zack Kimelheim",
//                    "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
//                    "lat" : 40.73058760000001,
//                    "lon" : -74.002141,
//                    "name" : "Joe's Pizza",
//                    "price_level" : 1,
//                    "rating" : 4.4
//                }
//            }
//        }
//    }

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import MapKit


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate  {
    
    //MARK: Firebase Properties
   // FIRApp.configure()
    @IBOutlet weak var map: MKMapView!
        var user: User!
    
    var searchController: UISearchController!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var annotation: MKAnnotation!
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        user = Auth.auth().currentUser
        //Configure Firebase app
        
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        locationManager?.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(MapVC.searchButtonAction(_:)))
        self.navigationItem.rightBarButtonItem = searchButton
        
        map.delegate = self
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        self.locationManager.stopUpdatingLocation()
        
        displayAllMarkers()
        
        map.showAnnotations(map.annotations, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
    }
    @objc func searchButtonAction(_ button: UIBarButtonItem) {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if self.map.annotations.count != 0 {
            annotation = self.map.annotations[0]
            self.map.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.map.centerCoordinate = pointAnnotation.coordinate
            self!.map.addAnnotation(pinAnnotationView.annotation!)
        }
    }
    func displayAllMarkers(){ Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").observe(.childAdded, with: { (snapshot) in
      //  print(self.user.uid)
        let value = snapshot.value as? [String:Any]
       print(value)
        let latitude = value?["lat"] as? Double ?? 0
        let longitude = value?["long"] as? Double ?? 0
//          let address = value["address"] as? String
            let friend = value?["from"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
//                let price = value["price"] as? NSInteger
//                let rating = value["rating"] as? Double
        
        print(latitude," ", longitude, " ", friend, " ", name)
                //make annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = name
                annotation.subtitle = friend
                self.map.addAnnotation(annotation)

        })}
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        if self.map.annotations.count != 0 {
            annotation = self.map.annotations[0]
            self.map.removeAnnotation(annotation)
        }
    }    
}

