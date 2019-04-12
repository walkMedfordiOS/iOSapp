//
//  LandmarkCreationView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 4/2/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LandmarkCreationView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    // Variables for color of elements
    var red = UIColor(red: 200, green: 0, blue: 0, alpha: 1)
    var green = UIColor(red: 0, green: 200, blue: 0, alpha: 1)
    var blue = UIColor(red: 0, green: 0, blue: 200, alpha: 1)
    
    // Variables for input information
    @IBOutlet weak var landmarkName: UITextField!
    @IBOutlet weak var landmarkDescription: UITextField!
    @IBOutlet weak var landmarkAddress: UITextField!
    @IBOutlet weak var landmarkImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var coordinates: CLLocationCoordinate2D!
    var imagePickerController : UIImagePickerController!
    var createdLandmark: Landmark!
    
    // Variables to show errors
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Variables to edit landmark
    var editLandmark: Landmark!
    var editImage: UIImage!
    var editIndex: Int!
    
    /*
     Purpose: To load the view
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        landmarkName.delegate = self
        landmarkDescription.delegate = self
        landmarkAddress.delegate = self
        
        mapView.delegate = self
        
        // If editing an existing landmark
        if (editLandmark != nil && editImage != nil) {
            fillLandmarkInfo()
        }
    }
    
    /*
     Purpose: To fill in the information if editing a landmark
     Notes:
     */
    func fillLandmarkInfo() {
        
        landmarkName.text = editLandmark.title
        landmarkDescription.text = editLandmark.description
        landmarkAddress.text = editLandmark.address
        landmarkImage.image = editImage
        
        convertAddress()
    }
    
    /*
     Purpose: To return to previous page
     Notes:
     */
    @IBAction func cancelLandmarkCreation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     Purpose: To hide the keyboard when the return key is pressed
     Notes:
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == landmarkName) {
            textField.resignFirstResponder()
            landmarkDescription.becomeFirstResponder()
        } else if (textField == landmarkDescription) {
            textField.resignFirstResponder()
            landmarkAddress.becomeFirstResponder()
        } else if (textField == landmarkAddress) {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    /*
     Purpose: To execute when address is completed
     Notes:
     */
    @IBAction func addressCompleted(_ sender: Any) {
        if (landmarkAddress.text != "") {
            convertAddress()
        }
    }
    
    /*
     Purpose: To convert the street address to latitude and longitude
     Notes:
    */
    func convertAddress() {
        let streetAddress = landmarkAddress.text!
        let address = "\(streetAddress) Medford, MA, USA"
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            if((error) != nil){
                print("Error", error as Any)
                self.errorLabel.text = "Make sure the street address is a valid address in Medford"
                self.errorLabel.isHidden = false
                return
            }
            if let placemark = placemarks?.first {
                self.coordinates = placemark.location!.coordinate
                self.setUpMap()
            }
        })
    }
    
    /*
     Purpose: To set up the map
     Notes:
     */
    func setUpMap() {
        centerOnLandmark()
        
        let landmarkAnnotation = LandmarkAnnotation(title: landmarkName.text!,
                                                    subtitle: landmarkAddress.text!,
                                                    coordinate: coordinates)
        self.mapView.addAnnotation(landmarkAnnotation)
    }
    
    /*
     Purpose: To center the map on the landmark
     Notes:
     */
    func centerOnLandmark() {
        let coordinateRegion = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: 2000, longitudinalMeters: 2000)
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
     Purpose: To add image
     Notes:
     */
    @IBAction func uploadImage(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    /*
     Purpose: To set landmarkImage once photo is chosen
     Notes:
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePickerController.dismiss(animated: true, completion: nil)
        landmarkImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    }
    
    /*
     Purpose: To create landmark
     Notes:
     */
    @IBAction func createLandmark(_ sender: Any) {
        
        if (allFieldsFilled()) {
            
            createdLandmark = Landmark(title: landmarkName.text!,
                                       latitude: coordinates.latitude,
                                       longitude: coordinates.longitude,
                                       address: landmarkAddress.text!,
                                       description: landmarkDescription.text!)
            
            // If editing a landmark
            if (editLandmark != nil && editImage != nil) {
                if let presenter = presentingViewController as? RouteCreationView {
                    
                    presenter.landmarks[editIndex] = createdLandmark
                    presenter.images[editIndex] = landmarkImage.image!
                    
                }
            } else {
                if let presenter = presentingViewController as? RouteCreationView {
                    
                    presenter.landmarks.append(createdLandmark)
                    presenter.images.append(landmarkImage.image!)
                    
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        } else {
            errorView.isHidden = false
        }
    }
    
    /*
     Purpose: To check that all fields are filled
     Notes:
     */
    func allFieldsFilled() -> Bool {
        var filled = true
        
        errorLabel.text = ""
        
        if (landmarkName.text == "") {
            print("Landmark Name Required")
            errorLabel.text = errorLabel.text! + "Landmark Name Required \n"
            filled = false
        }
        
        if (landmarkDescription.text == "") {
            print("Landmark Description Required")
            errorLabel.text = errorLabel.text! + "Landmark Description Required \n"
            filled = false
        }
        
        if (landmarkAddress.text == "") {
            print("Landmark Address Required")
            errorLabel.text = errorLabel.text! + "Landmark Address Required \n"
            filled = false
        }
        
        if (landmarkImage.image == nil) {
            print("Landmark Image Required")
            errorLabel.text = errorLabel.text! + "Landmark Image Required \n"
            filled = false
        }
        
        return filled
    }
    
    /*
     Purpose: To hide the errorView if button is pressed
     Notes:
     */
    @IBAction func cancelErrorView(_ sender: Any) {
        errorView.isHidden = true
    }
    
    /*
     Purpose: To pass data to next view
     Notes:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? RouteCreationView {
            destinationVC.landmarks.append(createdLandmark)
            destinationVC.images.append(landmarkImage.image!)
        }
    }
}
