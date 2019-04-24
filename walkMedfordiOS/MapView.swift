//
//  MapView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 11/26/18.
//  Copyright © 2018 walkMedford. All rights reserved.
//
import UIKit
import MapKit
import HealthKit

class MapView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let healthStore = HKHealthStore()
    
    // Variables for color of elements
    var red = UIColor(red: 150, green: 0, blue: 0, alpha: 1)
    var green = UIColor(red: 0, green: 150, blue: 0, alpha: 1)
    var blue = UIColor(red: 0, green: 0, blue: 150, alpha: 1)
    
    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Variables for Map, User Location, and Route
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var desiredRoute: Route?                            // User's chosen route
    var routePolyline : MKPolyline?                     // Line for route that visits landmarks
    var directionsToRoutePolyline : MKPolyline?         // Line for user to follow to get to the start of the route
    var landmarks = [Landmark]()
    
    // Variable for selected landmark by user
    var selectedLandmark: Landmark!
    
    // Variable for directions
    @IBOutlet weak var directionsInMapsButton: UIButton!
    @IBOutlet weak var cancelRouteButton: UIButton!
    
    /*
     Purpose: To call functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wakeUpServer()
        
        // Set up Map
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        directionsInMapsButton.isHidden = true
        cancelRouteButton.isHidden = true
        centerOnUser()
        setUpUserTrackingButton()
        getAllLandmarks()
    }
    
    /*
     Purpose: To set up the route on the map
     Notes:
     */
    func setUpRoute() {
        
        initPolyline()
        
        if (desiredRoute != nil) {
            addRoute()
        } else {
            print("DESIRED ROUTE NIL")
        }
    }
    
    /*
     Purpose: To set up user tracking button
     Notes:
     */
    func setUpUserTrackingButton() {
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.9).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60).isActive = true
        button.leadingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -50).isActive = true
    }
    
    /*
     Purpose: To center the map on the user
     Notes:
     */
    func centerOnUser() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            let healthKitTypes: Set = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
            ]
            healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (_, _) in
                print("authorized?")
            }
            healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
                if let e = error {
                    print("oops something went wrong during authorisation \(e.localizedDescription)")
                } else {
                    print("User has completed the authorization flow")
                }
            }
        }
    }

    /*
     Purpose: To update the user's location while moving around the map
     Notes:
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
    /*
     Purpose: To clear the map of overlays or annotations
     Notes:
     */
    func clearMap() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
 
    /*
     Purpose: To set up polyline
     Notes:
     */
    func initPolyline() {
        var polyInit = [CLLocationCoordinate2D]()
        
        if (desiredRoute == nil) {
            polyInit = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        } else {
            print(desiredRoute!.name)
            for landmark in desiredRoute!.landmarks {
                polyInit.append(landmark.location)
            }
        }
        
        routePolyline = MKPolyline(coordinates: &polyInit, count: polyInit.count)
        directionsToRoutePolyline = MKPolyline(coordinates: &polyInit, count: polyInit.count)
    }
    
    /*
     Purpose: To get all the landmarks
     Notes:
     */
    func getAllLandmarks() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/allLandmarks") {
            urlComponents.query = ""
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let json = JSON(data)
                    
                    // Adds landmarks to array of type Landmark
                    for (_,subJson):(String, JSON) in json {
                        let newLandmark = Landmark(id: subJson["landmark_id"].intValue,
                                                   title: subJson["landmark_name"].stringValue,
                                                   latitude: subJson["landmark_latitude"].doubleValue,
                                                   longitude: subJson["landmark_longitude"].doubleValue,
                                                   address: subJson["landmark_address"].stringValue,
                                                   description: subJson["landmark_description"].stringValue)
                        self.landmarks.append(newLandmark)
                    }
                    
                    for landmark in self.landmarks {
                        let landmarkAnnotation = LandmarkAnnotation(title: landmark.title,
                                                                    subtitle: landmark.address,
                                                                    coordinate: landmark.location)
                        self.mapView.addAnnotation(landmarkAnnotation)
                    }
                    
                    self.centerOnUser()
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To add the desired route to the map
     Notes:
     */
    func addRoute() {
        if (desiredRoute!.landmarks.count == 0) {
            return
        }
        
        // Create a walkable route, loop through and set walking paths between consecutive landmarks
        for index in 0..<(desiredRoute!.landmarks.count-1) {
            
            let sourceLocation = desiredRoute!.landmarks[index].location
            let destinationLocation = desiredRoute!.landmarks[index + 1].location
            
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .walking
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                
                // Sets up polyline on Map
                let route = response.routes[0]
                self.routePolyline = route.polyline
                self.mapView.addOverlay((self.routePolyline!), level: MKOverlayLevel.aboveRoads)
            }
        }
        
        centerOnUser()
        
        // Add annotations, landmarks, and directions to start
        //addStartEndAnnotations()
        addRouteFromUserToStart()
        addLandmarkAnnotations()
    }
    
    /*
     Purpose: To add annotations to the start and end of the desired route
     Notes:
     */
    func addStartEndAnnotations() {
        let sourceLocation = desiredRoute!.landmarks[0].location
        let destinationLocation = desiredRoute!.landmarks[desiredRoute!.landmarks.count - 1].location
        
        let startAnnotation = StartEndAnnotation(title: "Start of Route", coordinate: sourceLocation)
        let endAnnotation = StartEndAnnotation(title: "End of Route", coordinate: destinationLocation)
        
        self.mapView.addAnnotation(startAnnotation)
        self.mapView.addAnnotation(endAnnotation)
    }
    
    /*
     Purpose: To add route from user's location to start of desired route
     Notes:
     */
    func addRouteFromUserToStart() {
        let sourceLocation = locationManager.location!.coordinate
        let destinationLocation = desiredRoute!.landmarks[0].location
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            // Sets up polyline on Map
            let route = response.routes[0]
            self.directionsToRoutePolyline = route.polyline
            self.mapView.addOverlay((self.directionsToRoutePolyline!), level: MKOverlayLevel.aboveRoads)
            
            self.directionsInMapsButton.isHidden = false
            self.cancelRouteButton.isHidden = false
        }
        
        centerOnUser()
    }
    
    /*
     Purpose: To add landmarks along the route
     Notes: Bad way to add landmarks, need to add custom classes for separate annotations for landmarks and start and end of route
     */
    func addLandmarkAnnotations() {
        
        for landmark in desiredRoute!.landmarks {
            let landmarkAnnotation = LandmarkAnnotation(title: landmark.title,
                                                        subtitle: landmark.address,
                                                        coordinate: landmark.location)
            self.mapView.addAnnotation(landmarkAnnotation)
        }
        
        centerOnUser()
    }
    
    /*
     Purpose: To format the route lines
     Notes:
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5.0
        
        if overlay as? MKPolyline == routePolyline {
            renderer.strokeColor = red
        } else if overlay as? MKPolyline == directionsToRoutePolyline {
            renderer.strokeColor = blue
            renderer.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 10)]
        }
        
        return renderer
    }
    
    /*
     Purpose: To format the landmark annotations
     Notes:
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let annotation = annotation as? LandmarkAnnotation {
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            view.canShowCallout = true
            view.glyphImage = selectGlyph(name: annotation.title!)
            view.markerTintColor = red
            view.subtitleVisibility = MKFeatureVisibility.visible
            
        } else if let annotation = annotation as? StartEndAnnotation {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.markerTintColor = green
            
        } else {
            return nil
        }
        
        return view
    }
    
    /*
     Purpose: To choose the correct type of glyph image based on the landmark title
     Notes:
     */
    func selectGlyph(name: String) -> UIImage{
        
        var image = "building"
        
        if (name.contains("Park") || name.contains("Tree") || name.contains("Forest")) {
            image = "park"
        } else if (name.contains("School") || name.contains("College") || name.contains("University")) {
            image = "college"
        } else if (name.contains("Race Tracks") || name.contains("Race")) {
            image = "racetrack"
        } else if (name.contains("Garden")) {
            image = "garden"
        } else if (name.contains("House") || name.contains("Home") || name.contains("Estates") || name.contains("Farmhouse")) {
            image = "home"
        }
        
        return UIImage(named: image)!
    }
    
    /*
     Purpose: To show more information when landmark is selected
     Notes:
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if desiredRoute != nil {
            for landmark in desiredRoute!.landmarks {
                if (landmark.title == view.annotation?.title) {
                    selectedLandmark = landmark
                }
            }
        } else if landmarks.count != 0 {
            for landmark in landmarks {
                if (landmark.title == view.annotation?.title) {
                    selectedLandmark = landmark
                }
            }
        }
        
        performSegue(withIdentifier: "segueMapToLandmark", sender: self)
    }
    
    /*
     Purpose: To pass data to next view
     Notes:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueMapToLandmark") {
            if let destinationVC = segue.destination as? LandmarkView {
                destinationVC.landmark = selectedLandmark
            }
        }
    }
    
    /*
     Purpose: To open Apple Maps with directions to route
     Notes:
     */
    @IBAction func directionsInMapsButton(_ sender: Any) {
        
        let placemark = MKPlacemark(coordinate: desiredRoute!.landmarks[0].location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Start of Route"
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    /*
     Purpose: To wake up the Heroku server so it is prepared for requests in RouteSelectionView
     Notes:
     */
    func wakeUpServer() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/") {
            urlComponents.query = ""
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let _ = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    print("Server is woken up")
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To cancel the route
     Notes:
     */
    @IBAction func cancelRouteButton(_ sender: Any) {
        clearMap()
        cancelRouteButton.isHidden = true
        directionsInMapsButton.isHidden = true
        getAllLandmarks()
    }
    
}
