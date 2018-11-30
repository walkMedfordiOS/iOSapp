//
//  RouteSelectionView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 11/26/18.
//  Copyright © 2018 walkMedford. All rights reserved.
//

import UIKit
import CoreLocation

class RouteSelectionView: UIViewController {

    // Global Variables for selected route
    let routes = Routes()
    var desiredRoute = [CLLocationCoordinate2D]()
    
    /*
     Purpose: To call any functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     Purpose: To set global variable of selected route
     Notes: Does not work, finishes after segue
     */
    @IBAction func scholarsWalkChosen(_ sender: Any) {
        desiredRoute = routes.ScholarsWalkRoute
    }
    
    /*
     Purpose: To send selected route to ViewController so it can be plotted on route
     Notes: Figure out way to send selected route when there are multiple options
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.desiredRoute = routes.ScholarsWalkRoute
        }
    }
    
    
    

}
