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

class LandmarkCreationView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

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
    
    /*
     Purpose: To load the view
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
    }
    
    /*
     Purpose: To return to previous page
     Notes:
     */
    @IBAction func cancelLandmarkCreation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            if((error) != nil){
                print("Error", error as Any)
            }
            if let placemark = placemarks?.first {
                self.coordinates = placemark.location!.coordinate
            }
        })
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
