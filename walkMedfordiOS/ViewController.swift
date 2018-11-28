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
        }) { (animationComplete) in
            print(self.menuViewTrailing.constant)
        }
        
    }
    
    // Create Map
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLat: Double = 0
    var userLong: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set menu off screen
        menuViewTrailing.constant = -375
        chooseRoutesTrailing.constant = 0
        
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        centerOnUser()
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
    

}

