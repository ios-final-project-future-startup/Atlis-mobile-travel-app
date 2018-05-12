import UIKit
import MapKit
import Popover
import Firebase
import GoogleMaps
import GooglePlaces


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate  {
    // Properties
    var user: User!
    var searchController: UISearchController!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var annotation: MKAnnotation!
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView!
    var centeredMap: Bool!
    // Annotation Properties
    var filterBool = false
    var accomodationAnnotations = [MKAnnotation]()
    var bakeryAnnotations = [MKAnnotation]()
    var cafeAnnotations = [MKAnnotation]()
    var foodAnnotations = [MKAnnotation]()
    var nightLifeAnnotations = [MKAnnotation]()
    var pointsOfInterestAnnotations = [MKAnnotation]()
    var shoppingAnnotations = [MKAnnotation]()
    var unknownAnnotations = [MKAnnotation]()
    // Popover Properties
    fileprivate var pop: Popover!
    var point: CGPoint?
    var selectedRows = [Int]()
    var tableViewHolder: UIView?
    var tableView: UITableView?
    
    //Narrowed down the categories into the following themes
    var themes = ["Accomodation 🏠", "Bakeries 🥐", "Cafes ☕️", "Food 🍽", "Night Life 🍻🍾", "Point of Interest 🌎",
                  "Shopping 🛍"]
    // Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var filterBtn: UIButton!
    
    //map defaults to user's current location on load
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
        handleUserLocation()
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
        
        // Popover Set Up
        point = CGPoint(x: self.filterBtn.center.x, y: self.filterBtn.center.y)
        tableViewHolder = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/1.4, height: self.view.frame.height/2.35))
        self.tableView = UITableView(frame: CGRect(x: 0, y: 10, width: self.view.frame.width/1.4, height: self.view.frame.height/2.35))
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.allowsMultipleSelection = true
        self.tableView?.isScrollEnabled = true
        tableViewHolder?.addSubview(tableView!)
        tableView?.tableFooterView = UIView() // hide empty cells from footer
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
            
            //check the search
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
        // Firebase
        Database.database().reference().child("users").child(self.user.uid).child("saved_recommendations").observe(.value, with: { (snapshot) in
            //go through each database entry
            if let value = snapshot.value as? [String:[String:Any]] {
                //query the data
                for (_, v) in value {
                    let address = v["address"] as? String ?? "Unknown"
                    let friend = v["from"] as? String ?? "Unknown"
                    let name = v["name"] as? String ?? "Unknown"
                    // Make annotation off of queries
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
                            //add default values to annotation if value is null
                            if let rating = v["rating"] as? Double { annotation.rating = rating }
                            //Separate categories
                            if let category = v["category"] as? String {
                                annotation.category = category
                                // add to arrays for filtering
                                if category == "accomodation" {
                                    self.accomodationAnnotations.append(annotation)
                                } else if category == "bakery" {
                                    self.bakeryAnnotations.append(annotation)
                                } else if category == "cafe" {
                                    self.cafeAnnotations.append(annotation)
                                } else if category == "food" {
                                    self.foodAnnotations.append(annotation)
                                } else if category == "night_life" {
                                    self.nightLifeAnnotations.append(annotation)
                                } else if category == "point_of_interest" {
                                    self.pointsOfInterestAnnotations.append(annotation)
                                } else if category == "shopping" {
                                    self.shoppingAnnotations.append(annotation)
                                }
                            } else {
                                annotation.category = "unknown"
                                self.unknownAnnotations.append(annotation)
                            }
                            print("Testing: \(annotation.category ?? "no category")")
                            //self.map.addAnnotation(annotation)
                        }
                    }
                }
                self.addAllAnnotationsToMap()
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
    
    //Callouts
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
    
    //Populate map with annotations
    func addAllAnnotationsToMap() {
        self.map.removeAnnotations(map.annotations) // remove all annotations from map
        // MARK: TODO -- could use dictionary for arrays and loop thru
        self.map.addAnnotations(accomodationAnnotations)
        self.map.addAnnotations(bakeryAnnotations)
        self.map.addAnnotations(cafeAnnotations)
        self.map.addAnnotations(foodAnnotations)
        self.map.addAnnotations(nightLifeAnnotations)
        self.map.addAnnotations(pointsOfInterestAnnotations)
        self.map.addAnnotations(shoppingAnnotations)
        self.map.addAnnotations(unknownAnnotations)
    }
    
    func annotationFilter() {
        if filterBool == false { // check if first time filtered
            // Remove all annotations
            let allAnnotations = self.map.annotations
            self.map.removeAnnotations(allAnnotations)
            // Add selected annotations
            if selectedRows.contains(0) { self.map.addAnnotations(accomodationAnnotations) } // Accomodation
            if selectedRows.contains(1) { self.map.addAnnotations(bakeryAnnotations) } // Bakeries
            if selectedRows.contains(2) { self.map.addAnnotations(cafeAnnotations) } // Cafes
            if selectedRows.contains(3) { self.map.addAnnotations(foodAnnotations) } // Food
            if selectedRows.contains(4) { self.map.addAnnotations(nightLifeAnnotations) } // Night Life
            if selectedRows.contains(5) { self.map.addAnnotations(pointsOfInterestAnnotations) } // POIs
            if selectedRows.contains(6) { self.map.addAnnotations(shoppingAnnotations) } // Shopping
            filterBool = true
        } else {
            if selectedRows.count == 0 {
                addAllAnnotationsToMap()
            } else {
                // Remove all annotations
                let allAnnotations = self.map.annotations
                self.map.removeAnnotations(allAnnotations)
                // Add selected annotations
                if selectedRows.contains(0) { self.map.addAnnotations(accomodationAnnotations) } // Accomodation
                if selectedRows.contains(1) { self.map.addAnnotations(bakeryAnnotations) } // Bakeries
                if selectedRows.contains(2) { self.map.addAnnotations(cafeAnnotations) } // Cafes
                if selectedRows.contains(3) { self.map.addAnnotations(foodAnnotations) } // Food
                if selectedRows.contains(4) { self.map.addAnnotations(nightLifeAnnotations) } // Night Life
                if selectedRows.contains(5) { self.map.addAnnotations(pointsOfInterestAnnotations) } // POIs
                if selectedRows.contains(6) { self.map.addAnnotations(shoppingAnnotations) } // Shopping
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func filterBtnTapped(_ sender: Any) {
        let options = [
            .type(.down),
            .animationIn(0.3),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
            //.arrowSize(CGSize.zero)
            ] as [PopoverOption]
        self.pop = Popover(options: options, showHandler: nil, dismissHandler: nil)
        self.pop.show(tableViewHolder!, point: point!)
    }
    
    
    // MARK: Segue
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {}    
}

// MARK: TableViewDelegate
extension MapVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //cell?.selectionStyle = .none // don't show the standard gray selection color
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        selectedRows.append(indexPath.row)
        annotationFilter()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.none
        selectedRows = selectedRows.filter {$0 != indexPath.row}
        annotationFilter()
    }
}
// MARK: TableViewDataSource
extension MapVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if selectedRows.contains(indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        cell.textLabel?.text = self.themes[(indexPath as NSIndexPath).row]
        cell.textLabel?.font = AvenirNext(size: 17.0)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
}

