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
    @IBOutlet weak var hamburgerMenuView: UIView!
    var menuIsVisible = false
    
    /*
     Purpose: To shift the menuView when hamburger icon is tapped
     Notes: 
    */
    @IBAction func showMenu(_ sender: Any) {
        if (!menuIsVisible) {
            hamburgerMenuView.isHidden = false
        } else {
            hamburgerMenuView.isHidden = true
        }
        menuIsVisible = !menuIsVisible
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:  {
            self.view.layoutIfNeeded()
        })
        
    }
    
    // Global Variables for Map, User Location, and Route
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var desiredRoute = [Landmark]()       // User's selected route
    var routePolyline : MKPolyline?                     // Line for route that visits landmarks
    var directionsToRoutePolyline : MKPolyline?         // Line for user to follow to get to the start of the route
    
    /*
     Purpose: To call functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set menuView off screen
        hamburgerMenuView.isHidden = true
        
        // Set up Map
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
        centerOnUser()
        
        // Initialize polylines
        var polyInit = [CLLocationCoordinate2D]()
        for landmark in desiredRoute {
            polyInit.append(landmark.location)
        }
        
        if desiredRoute.isEmpty {
            polyInit = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        }
        routePolyline = MKPolyline(coordinates: &polyInit, count: polyInit.count)
        directionsToRoutePolyline = MKPolyline(coordinates: &polyInit, count: polyInit.count)
        
        // Show selected route on Map
        if (!desiredRoute.isEmpty) {
            addRoute()
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
    func addRoute() {
        if (desiredRoute.count == 0) {
            return
        }
        
        // Create a walkable route, loop through and set walking paths between consecutive landmarks
        for index in 0..<(desiredRoute.count-1) {
        
            let sourceLocation = desiredRoute[index].location
            let destinationLocation = desiredRoute[index + 1].location
            
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
                
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        // Add annotations, landmarks, and directions to start
        //addStartEndAnnotations()
        addRouteFromUserToStart()
        addLandmarkAnnotations()
    }
    
    /*
     Purpose: To add annotations to the start and end of the desired route
     Notes: Need to create a custom class for start/end annotations
     */
    func addStartEndAnnotations() {
        let sourceLocation = desiredRoute[0].location
        let destinationLocation = desiredRoute[desiredRoute.count - 1].location
        
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
    func addLandmarkAnnotations() {
        
        for landmark in desiredRoute {
            let landmarkAnnotation = LandmarkAnnotation(title: landmark.title,
                                                        coordinate: landmark.location)
            self.mapView.addAnnotation(landmarkAnnotation)
        }
    }
    
    /*
     Purpose: To add route from user's location to start of desired route
     Notes:
     */
    func addRouteFromUserToStart() {
        let sourceLocation = locationManager.location!.coordinate
        let destinationLocation = desiredRoute[0].location
        
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
    
    // Added a comment to see if Macincloud works
}

