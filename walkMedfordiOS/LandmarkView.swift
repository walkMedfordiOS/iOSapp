//
//  LandmarkView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/7/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorage

class LandmarkView: UIViewController, MKMapViewDelegate {

    // Variables for color of elements
    var red = UIColor(red: 200, green: 0, blue: 0, alpha: 1)
    var green = UIColor(red: 0, green: 200, blue: 0, alpha: 1)
    var blue = UIColor(red: 0, green: 0, blue: 200, alpha: 1)
    
    // Landmark information labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Landmark location and image
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    // Selected landmark variable
    var landmark: Landmark!
    
    // To show loading
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    /*
     Purpose: To load variables when view has loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        titleLabel.text = landmark.title
        addressLabel.text = landmark.address
        descriptionLabel.text = landmark.description
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        setUpImage()
        setUpMap()
    }
    
    /*
     Purpose: To set up the image
     Notes:
     */
    func setUpImage() {

        var filename = landmark.title.replacingOccurrences(of: " ", with: "_")
        filename = filename.replacingOccurrences(of: "/", with: "_")
        filename = filename.replacingOccurrences(of: "\\", with: "_")
        filename = filename.replacingOccurrences(of: ":", with: "_")
        filename = filename.replacingOccurrences(of: ",", with: "_")
        filename += ".jpg"
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let imagesRef = storageRef.child(filename)
       
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("ERROR: \(error)")
            } else {
                self.imageView.image = UIImage(data: data!)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    /*
     Purpose: To set up the map
     Notes:
     */
    func setUpMap() {
        centerOnLandmark()
        
        let landmarkAnnotation = LandmarkAnnotation(title: landmark.title,
                                                    subtitle: landmark.address,
                                                    coordinate: landmark.location)
        self.mapView.addAnnotation(landmarkAnnotation)
    }
    
    /*
     Purpose: To center the map on the landmark
     Notes:
     */
    func centerOnLandmark() {
        let coordinateRegion = MKCoordinateRegion.init(center: landmark.location, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
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
            
            view.canShowCallout = false
            view.glyphImage = selectGlyph(name: annotation.title!)
            view.markerTintColor = red
            view.subtitleVisibility = MKFeatureVisibility.visible
            
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
     Purpose: To send the user back
     Notes:
    */
    @IBAction func backButton(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
}
