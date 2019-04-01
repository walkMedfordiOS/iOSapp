//
//  LandmarkView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/7/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import MapKit

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
        
        setUpImage()
        setUpMap()
    }
    
    /*
     Purpose: To set up the image
     Notes:
     */
    func setUpImage() {
        var image = landmark.title.replacingOccurrences(of: " ", with: "_")
        image = image.replacingOccurrences(of: "/", with: "_")
        print("Image name: \(image)")
        imageView.image = UIImage(named: image)
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
            view.glyphImage = UIImage(named: annotation.imageName ?? "landmark")
            view.markerTintColor = red
            view.subtitleVisibility = MKFeatureVisibility.visible
            
        } else {
            return nil
        }
        
        return view
    }
    
    /*
     Purpose: To send the user back
     Notes:
    */
    @IBAction func backButton(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
}
