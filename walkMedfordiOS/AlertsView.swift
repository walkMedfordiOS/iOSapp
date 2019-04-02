//
//  AlertsView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/14/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit

class AlertsView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     Purpose: To pass data to next view
     Notes:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "snowRemovalSegue") {
            if let destinationVC = segue.destination as? WebView {
                destinationVC.website = "https://www.medfordma.org/2018/12/04/reminder-snow-removal-regulations/"
            }
        } else if (segue.identifier == "reportIssueSegue") {
            if let destinationVC = segue.destination as? WebView {
                destinationVC.website = "https://en.seeclickfix.com/medford_3"
            }
        } else if (segue.identifier == "cityMedfordSegue") {
            if let destinationVC = segue.destination as? WebView {
                destinationVC.website = "https://www.medfordma.org/"
            }
        }
    }
   
}
