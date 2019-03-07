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
    
    var landmark: Landmark!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = landmark.title
        addressLabel.text = landmark.address
        descriptionLabel.text = landmark.description
    }

}
