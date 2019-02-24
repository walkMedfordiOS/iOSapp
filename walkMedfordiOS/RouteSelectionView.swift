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
    var desiredRoute = [Landmark]()
    
    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    /*
     Purpose: To call any functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRoutes()
    }
    
    /*
     Purpose: To get all the walking routes
     Notes:
     */
    func getRoutes() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/allRoutes") {
            urlComponents.query = ""
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    // Do something with results
                    print("Data: \(String(data: data, encoding: .utf8))")
                }
            }
        }
        
        dataTask?.resume()
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
        if segue.destination is MapView
        {
            let vc = segue.destination as? MapView
            vc?.desiredRoute = routes.ScholarsWalkRoute
        }
    }
    
    
    
    
}
