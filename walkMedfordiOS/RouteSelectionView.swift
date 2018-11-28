//
//  RouteSelectionView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 11/26/18.
//  Copyright © 2018 walkMedford. All rights reserved.
//

import UIKit

class RouteSelectionView: UIViewController {

    let routes = Routes()
    var desiredRoute = [(Latitude: Double,Longitude: Double)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func scholarsWalkChosen(_ sender: Any) {
        desiredRoute = routes.ScholarsWalkRoute
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.desiredRoute = routes.ScholarsWalkRoute
        }
    }
    
    
    

}
