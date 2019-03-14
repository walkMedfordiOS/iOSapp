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
     Purpose: To send user to snow removal website
     Notes:
    */
    @IBAction func websiteButton(_ sender: Any) {
        guard let url = URL(string: "http://www.medfordma.org/2018/12/04/reminder-snow-removal-regulations/") else { return }
        UIApplication.shared.open(url)
    }
    
}
