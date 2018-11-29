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

    // Create Hamburger Menu
    @IBOutlet weak var menuViewLeading: NSLayoutConstraint!
    @IBOutlet weak var menuViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var chooseRoutesLeading: NSLayoutConstraint!
    @IBOutlet weak var chooseRoutesTrailing: NSLayoutConstraint!
    var menuIsVisible = false
    
    // Shift view when hamburger icon is tapped
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
    
    // Create Map
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLat: Double = 0
    var userLong: Double = 0
    var desiredRoute = [(Latitude: Double,Longitude: Double)]()
    
    // Variables for two different polylines, one for route another for directions to route
    //var routePolyline : MKPolyline
    //var directionsToRoutePolyline : MKPolyline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set menu off screen
        menuViewTrailing.constant = -375
        chooseRoutesTrailing.constant = 0
        
        // Set up Map
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
        centerOnUser()
        
        // Initialize polylines
        //routePolyline = MKPolyline(coordinates: &desiredRoute, count: desiredRoute.count)
        //directionsToRoutePolyline = MKPolyline(coordinates: &desiredRoute, count: desiredRoute.count)
        
        // Show selected route on Map
        if !desiredRoute.isEmpty {
            addRoute(route: desiredRoute)
        }
    }

    // Center map on User's location
    func centerOnUser() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Update User's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        userLat = location.coordinate.latitude
        userLong = location.coordinate.longitude
        
        locationManager.stopUpdatingLocation()
    }
    
    // When crosshairs button is tapped recenter map on user's location
    @IBAction func reCenter(_ sender: Any) {
        centerOnUser()
    }
    
    // Plot a route on the map
    func addRoute(route: [(Latitude: Double,Longitude: Double)]) {
        if route.count == 0 {
            return
        }
        var pointsToUse: [CLLocationCoordinate2D] = []
        
        for i in 0...route.count-1 {
            let x = CLLocationDegrees(route[i].Latitude)
            let y = CLLocationDegrees(route[i].Longitude)
            pointsToUse += [CLLocationCoordinate2DMake(x, y)]
        }
        
        // Change to use global variables of polylines
        let routePolyline = MKGeodesicPolyline(coordinates: &pointsToUse, count: route.count)
        mapView.addOverlay(routePolyline)
        
        addSourceDestinationAnnotations(route: route)
        addRouteToScholarsWalk()
        addLandmarks()
    }
    
    // Add markers for start and end of route
    func addSourceDestinationAnnotations(route: [(Latitude: Double,Longitude: Double)]) {
        let sourceLocation = CLLocationCoordinate2D(latitude: route[0].Latitude, longitude: route[0].Longitude)
        let destinationLocation = CLLocationCoordinate2D(latitude: route[route.count - 1].Latitude, longitude: route[route.count - 1].Longitude)
        
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
    
    // Format the route line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 4.0
        renderer.strokeColor = UIColor.red

        // Change format of Routes array to be CLLocation2D so this can be used for different colors
//        if overlay is MKPolyline {
//            if overlay as? MKPolyline == routePolyline {
//                renderer.strokeColor = UIColor.red
//            } else if overlay as? MKPolyline == directionsToRoutePolyline {
//                renderer.strokeColor = UIColor.blue
//            }
//        }
        
        return renderer
    }
    
    
    
    
    
    
    // shitty way to add landmarks, need to add custom classes for separate annotations for landmarks and start and end of route
    func addLandmarks() {
        var sourceLocation = CLLocationCoordinate2D(latitude: 42.412382, longitude: -71.111524)
        var sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        var sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Royall House and Slave Quarters"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        
        
        
        
        sourceLocation = CLLocationCoordinate2D(latitude: 42.417404, longitude: -71.114892)
        sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Poet John Ciardi's House"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        
        
        
        
        
        sourceLocation = CLLocationCoordinate2D(latitude: 42.412961, longitude: -71.110786)
        sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "James Curtis House"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
        
        
        
        
        
        
        
        
        sourceLocation = CLLocationCoordinate2D(latitude: 42.401953, longitude: -71.108229)
        sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Tufts Park"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation], animated: true )
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Reformat to add route from user's location to desiredRoute
    func addRouteToScholarsWalk() {
        let sourceLocation = CLLocationCoordinate2D(latitude: 42.406906, longitude: -71.117560)
        let destinationLocation = CLLocationCoordinate2D(latitude: 42.401613, longitude: -71.106343)
        
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
            
            
            // Chang to use global variable
            let route = response.routes[0]
            let directionsToRoutePolyline = route.polyline
            self.mapView.addOverlay((directionsToRoutePolyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    

}

