import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import MapKit

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate  {
    // Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var filterBtn: UIButton!
    
        var user: User!


    var searchController: UISearchController!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var annotation: MKAnnotation!
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView!
    var centeredMap: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
        handleUserLocation()
        //displayAllMarkers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
        displayAllMarkers()
    }
    
    func setUpVC() {
        self.title = "Your Map"
        user = Auth.auth().currentUser // create firebase user
        self.definesPresentationContext = true
        // Handle location manager + map
        if locationManager == nil { locationManager = CLLocationManager() }
        locationManager?.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.map.delegate = self
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        self.locationManager.stopUpdatingLocation()
        self.map.showsCompass = false;
        // Search Bar Button
        var searchBtnImage = UIImage(named: "Search.png")
        searchBtnImage = searchBtnImage?.withRenderingMode(.alwaysOriginal)
        let searchButton = UIBarButtonItem(image: searchBtnImage, style:.plain, target: self, action: #selector(MapVC.searchButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = searchButton
        // Add Bar Button
        var addBtnImage = UIImage(named: "Icon.png")
        addBtnImage = addBtnImage?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addBtnImage, style:.plain, target: self, action: #selector(addBtnClicked))
    }
    
    func handleUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.centeredMap = false
            self.map.showsUserLocation = true
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @objc func addBtnClicked() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        performSegue(withIdentifier: "add", sender: nil)
    }
    
    // MARK: - UISearchBarDelegate
    @objc func searchButtonAction(_ button: UIBarButtonItem) {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }

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
            
            self!.map.centerCoordinate = pointAnnotation.coordinate
        }
    }
    
    func displayAllMarkers(){
        //Reload map
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        // Firebase
        Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String:[String:Any]] {
                for (_, v) in value {
                    let address = v["address"] as? String ?? "Unknown"
                    let friend = v["from"] as? String ?? "Unknown"
                    let name = v["name"] as? String ?? "Unknown"
                    // make annotation
                    if let latitude = v["lat"] as? Double {
                        if let longitude = v["lon"] as? Double {
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let annotation = PlaceAnnotation(coordinate:coordinate)
                            annotation.address = address
                            annotation.name = name
                            annotation.recommendedBy = friend
                            annotation.subtitle = friend
                            if let price_level = v["price_level"] as? Double {
                                if price_level < 0 { annotation.price_level = 3.0 }
                                else { annotation.price_level = price_level }
                            }
                            if let rating = v["rating"] as? Double { annotation.rating = rating }
                            self.map.addAnnotation(annotation)
                        }
                    }
                }
            }
        })}
    
    // MARK: MapView Delegate Functions
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil } // don't add a user annotation
        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil { // hasn't been created yet
            annotationView = PlaceAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        } else { // use the view already created
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "custom_mark") // set the marker image
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return } // don't display custom calloutview
        if let placeAnnotation = view.annotation as? PlaceAnnotation {
            let views = Bundle.main.loadNibNamed("PlaceCallOutView", owner: nil, options: nil)
            let calloutView = views?[0] as? PlaceCallOutView
            calloutView?.placeNameLabel.text = placeAnnotation.name
            calloutView?.recommendedByLabel.text = "from \(placeAnnotation.recommendedBy!)"
            calloutView?.addressLabel.text = "Address: \(placeAnnotation.address!)"
            if let priceLevel = placeAnnotation.price_level {
                calloutView?.priceLabel.text = "Price: \(priceLevel)/5"
            } else {
                calloutView?.priceLabel.text = "Unknown"
            }
            if let rating = placeAnnotation.rating {
                calloutView?.ratingLabel.text = "Rating: \(rating)/5"
            } else {
                calloutView?.ratingLabel.text = "Unknown"
            }
            
            //let button = UIButton(frame: calloutView.starbucksPhone.frame)
            //button.addTarget(self, action: #selector(ViewController.callPhoneNumber(sender:)), for: .touchUpInside)
            //calloutView.addSubview(button)

            let heightValue = -((calloutView?.bounds.size.height)! * 0.52)
            calloutView?.center = CGPoint(x: view.bounds.size.width / 2, y: heightValue)
            view.addSubview(calloutView!)
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        } else {
            return
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: PlaceAnnotationView.self) {
            for subview in view.subviews { subview.removeFromSuperview() } // remove all the superviews
        }
    }
    
    // MARK: Segue
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {}    
}

