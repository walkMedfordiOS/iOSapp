//
//  LandmarkView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/7/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit

class LandmarkView: UIViewController {

    // Landmark information labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Selected landmark variable
    var landmark: Landmark!
    
    /*
     Purpose: To load variables when view has loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = landmark.title
        addressLabel.text = landmark.address
        descriptionLabel.text = landmark.description
    }
    
    /*
     Purpose: To send the user back
     Notes:
    */
    @IBAction func backButton(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     Purpose: To show the landmark on the map
     Notes:
     */
    @IBAction func mapViewButton(_ sender: Any) {

        performSegue(withIdentifier: "segueLandmarktoMap", sender: self)
    }
    
    /*
     Purpose: To pass data to next view
     Notes:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if (segue.identifier == "segueLandmarktoMap") {
            if let destinationVC = segue.destination as? MapView {
                destinationVC.desiredLandmark = landmark
            }
        }
    }
}
