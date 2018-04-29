import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import MapKit

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate  {
    
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
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
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.map.centerCoordinate = pointAnnotation.coordinate
            self!.map.addAnnotation(pinAnnotationView.annotation!)
        }
    }
    
    func displayAllMarkers(){
        Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").observe(.value, with: { (snapshot) in
            print("Testing: \(self.user.uid)")
            //var longitude: Double
            let value = snapshot.value as! [String:[String:Any]]
            for (_, v) in value {
                let address = v["address"] as? String ?? "Unknown"
                let friend = v["from"] as? String ?? "Unknown"
                let name = v["name"] as? String ?? "Unknown"
                // make annotation
                if let latitude = v["lat"] as? Double {
                    if let longitude = v["lon"] as? Double {
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let annotation = Place(coordinate:coordinate)
                        annotation.address = address
                        annotation.name = name
                        annotation.subtitle = friend
                        if let price_level = v["price_level"] as? Double {
                            annotation.price_level = price_level
                        }
                        if let rating = v["rating"] as? Double {
                            annotation.rating = rating
                        }
                        self.map.addAnnotation(annotation)
                    }
                }
            }
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
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        map.addAnnotation(pointAnnotation)
    }
    
    // MARK: Segue
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {}    
}

