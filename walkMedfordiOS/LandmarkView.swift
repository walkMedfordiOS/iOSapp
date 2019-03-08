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
    
}
