//
//  LandmarkCreationView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 4/2/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import CoreLocation

class LandmarkCreationView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // Variables for input information
    @IBOutlet weak var landmarkName: UITextField!
    @IBOutlet weak var landmarkDescription: UITextField!
    @IBOutlet weak var landmarkAddress: UITextField!
    @IBOutlet weak var landmarkImage: UIImageView!
    var coordinates: CLLocationCoordinate2D!
    var imagePickerController : UIImagePickerController!
    var createdLandmark: Landmark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let streetAddress = landmarkAddress.text as! String
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
        }
    }
    
    /*
     Purpose: To check that all fields are filled
     Notes:
     */
    func allFieldsFilled() -> Bool {
        var filled = true
        
        if (landmarkName.text == "") {
            print("Landmark Name Required")
            filled = false
        }
        
        if (landmarkDescription.text == "") {
            print("Landmark Description Required")
            filled = false
        }
        
        if (landmarkAddress.text == "") {
            print("Landmark Address Required")
            filled = false
        }
        
        if (landmarkImage.image == nil) {
            print("Landmark Image Required")
            filled = false
        }
        
        return filled
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
