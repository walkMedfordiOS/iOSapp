//
//  LandmarkView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/5/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import UIKit

class LandmarkView: UIViewController {
    
    // Variable for landmark
    var landmark: Landmark?
    
    // Variables for labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /*
     Purpose: To call functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (landmark != nil) {
            print(landmark!.address)
        }
    }
}
