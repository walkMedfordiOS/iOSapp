//
//  LandmarkView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/7/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import MapKit
import Contentful

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

        imageView.image = convertImage()
    }
    
    func convertImage() -> UIImage? {
//        var strings = cadenaImagen.components(separatedBy: ",")
//        var bytes = [UInt8]()
//        for i in 0..<strings.count {
//            if let signedByte = Int8(strings[i]) {
//                bytes.append(UInt8(bitPattern: signedByte))
//            } else {
//                // Do something with this error condition
//            }
//        }
        let bytes: [UInt8] = [47,57,106,47,52,65,65,81,83,107,90,74,82,103,65,66,65,81,65,65,116,65,67,48,65,65,68,47,52,81,76,85,82,88,104,112,90,103,65,65,84,85,48,65,75,103,65,65,65,65,103,65,67,81,69,79,65,65,73,65,65,65,65,103,65,65,65,65,101,103,69,80,65,65,73,65,65,65,65,71,65,65,65,65,109,103,69,81,65,65,73,65,65,65,65,90,65,65,65,65,111,65,69,83,65,65,77,65,65,65,65,66,65,65,69,65,65,65,69,97,65,65,85,65,65,65,65,66,65,65,65,65,117,103,69,98,65,65,85,65,65,65,65,66,65,65,65,65,119,103,69,111,65,65,77,65,65,65,65,66,65,65,73,65,65,65,69,121,65,65,73,65,65,65,65,85,65,65,65,65,121,111,100,112,65,65,81,65,65,65,65,66,65,65,65,65,51,103,65,65,65,65,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,73,67,65,103,65,69,78,104,98,109,57,117,65,69,78,104,98,109,57,117,73,70,66,118,100,50,86,121,85,50,104,118,100,67,66,84,87,68,69,49,77,67,66,74,85,119,65,65,65,65,65,65,116,65,65,65,65,65,69,65,65,65,67,48,65,65,65,65,65,84,73,119,77,84,73,54,77,68,99,54,77,106,69,103,77,84,65,54,77,122,89,54,78,68,107,65,65]
        let datos: NSData = NSData(bytes: bytes, length: bytes.count)
        return UIImage(data: datos as Data) // Note it's optional. Don't force unwrap!!!
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
