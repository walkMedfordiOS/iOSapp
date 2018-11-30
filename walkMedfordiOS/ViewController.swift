//
//  ViewController.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 11/26/18.
//  Copyright © 2018 walkMedford. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // Global Variables for Hamburger Menu
    @IBOutlet weak var menuViewLeading: NSLayoutConstraint!
    @IBOutlet weak var menuViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var chooseRoutesLeading: NSLayoutConstraint!
    @IBOutlet weak var chooseRoutesTrailing: NSLayoutConstraint!
    var menuIsVisible = false
    
    /*
     Purpose: To shift the menuView when hamburger icon is tapped
     Notes: Currently have to individually shift menuView and button
    */
    @IBAction func showMenu(_ sender: Any) {
        if !menuIsVisible {
            menuViewLeading.constant = 0
            menuViewTrailing.constant = 0
            chooseRoutesLeading.constant = 0
            chooseRoutesTrailing.constant = 0
            menuIsVisible = true
        } else {
            menuViewLeading.constant = 0
            menuViewTrailing.constant = -375
            chooseRoutesLeading.constant = -375
            chooseRoutesTrailing.constant = 0
            menuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:  {
            self.view.layoutIfNeeded()
        })
        
    }
    
    // Global Variables for Map, User Location, and Route
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var desiredRoute = [CLLocationCoordinate2D]()
    var routePolyline : MKPolyline?
    var directionsToRoutePolyline : MKPolyline?
    
    /*
     Purpose: To call functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set menuView off screen
        menuViewTrailing.constant = -375
        chooseRoutesTrailing.constant = 0
        
        // Set up Map
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
        centerOnUser()
        
        // Initialize polylines
        var polyInit = desiredRoute
        if desiredRoute.isEmpty {
            polyInit = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        }
        routePolyline = MKPolyline(coordinates: &polyInit, count: polyInit.count)
        directionsToRoutePolyline = MKPolyline(coordinates: &polyInit, count: polyInit.count)
        
        // Show selected route on Map
        if !desiredRoute.isEmpty {
            addRoute(route: desiredRoute)
        }
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
     Purpose: To recenter the map on the user when crosshairs button is tapped
     Notes:
     */
    @IBAction func reCenter(_ sender: Any) {
        centerOnUser()
    }
    
    /*
     Purpose: To add the desired route to the map
     Notes:
     */
    func addRoute(route: [CLLocationCoordinate2D]) {
        if route.count == 0 {
            return
        }
        var pointsToUse: [CLLocationCoordinate2D] = []
        
        for i in 0...route.count-1 {
            let x = CLLocationDegrees(route[i].latitude)
            let y = CLLocationDegrees(route[i].longitude)
            pointsToUse += [CLLocationCoordinate2DMake(x, y)]
        }
        
        // Create route polyline
        routePolyline = MKGeodesicPolyline(coordinates: &pointsToUse, count: route.count)
        mapView.addOverlay(routePolyline!)
        
        // Add annotations, landmarks, and directions to start
        addSourceDestinationAnnotations(route: route)
        addRouteFromUserToStart()
        addLandmarks()
    }
    
    /*
     Purpose: To add annotations to the start and end of the desired route
     Notes: Need to create a custom class for start/end annotations
     */
    func addSourceDestinationAnnotations(route: [CLLocationCoordinate2D]) {
        let sourceLocation = CLLocationCoordinate2D(latitude: route[0].latitude, longitude: route[0].longitude)
        let destinationLocation = CLLocationCoordinate2D(latitude: route[route.count - 1].latitude, longitude: route[route.count - 1].longitude)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Start"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "End"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
    }
    
    /*
     Purpose: To format the route lines
     Notes:
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0

        if overlay is MKPolyline {
            if overlay as? MKPolyline == routePolyline {
                renderer.strokeColor = UIColor.red
            } else if overlay as? MKPolyline == directionsToRoutePolyline {
                renderer.strokeColor = UIColor.blue
            }
        }
        
        return renderer
    }
    
    /*
     Purpose: To add landmarks along the route
     Notes: Bad way to add landmarks, need to add custom classes for separate annotations for landmarks and start and end of route
            Also loop to add landmarks from an array
     */
    func addLandmarks() {
        // Adds Royall House
        var sourceLocation = CLLocationCoordinate2D(latitude: 42.412382, longitude: -71.111524)
        var sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        var sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Royall House and Slave Quarters"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        // Adds John Ciardi's House
        sourceLocation = CLLocationCoordinate2D(latitude: 42.417404, longitude: -71.114892)
        sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Poet John Ciardi's House"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        // Adds James Curtis House
        sourceLocation = CLLocationCoordinate2D(latitude: 42.412961, longitude: -71.110786)
        sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "James Curtis House"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        // Adds Tufts Park
//        sourceLocation = CLLocationCoordinate2D(latitude: 42.401953, longitude: -71.108229)
//        sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
//        sourceAnnotation = MKPointAnnotation()
//        sourceAnnotation.title = "Tufts Park"
//
//        if let location = sourcePlacemark.location {
//            sourceAnnotation.coordinate = location.coordinate
//        }
//
//        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        
        
        
        
        let landmarkAnnotation = LandmarkAnnotation(title: "Tufts Park",
                                                    coordinate: CLLocationCoordinate2D(latitude: 42.401953, longitude: -71.108229))
        self.mapView.addAnnotation(landmarkAnnotation)
        
        
        
        
    }
    
    /*
     Purpose: To add route from user's location to start of desired route
     Notes:
     */
    func addRouteFromUserToStart() {
        let sourceLocation = locationManager.location!.coordinate
        let destinationLocation = desiredRoute[0]
        
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
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    

}

