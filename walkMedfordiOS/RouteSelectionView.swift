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
    var routes = [Route]()
    var desiredRoute = Route(id: 0, name: "", description: "")
    
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
                    
                    let json = JSON(data)
                    
                    // Adds routes to array of type Route
                    for (_,subJson):(String, JSON) in json {
                        let newRoute = Route(id: subJson["route_id"].intValue, name: subJson["route_name"].stringValue, description: subJson["route_description"].stringValue)
                        self.routes.append(newRoute)
                    }
                    
                    self.fillRouteTable()
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To populate table with routes
     Notes:
     */
    func fillRouteTable() {
        // Fill table with routes
        
        self.desiredRoute = routes[0]
        getRouteInfo()
    }
    
    /*
     Purpose: Get all the landmarks of the chosen route
     Notes:
     */
    func getRouteInfo() {
        let routeID = self.desiredRoute.id
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/oneRoute") {
            urlComponents.query = "route=\(routeID)"
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let json = JSON(data)
                    
                    // Adds landmarks to array of type Landmark in desiredRoute
                    for (_,subJson):(String, JSON) in json {
                        self.desiredRoute.landmarks.append(
                            Landmark(title: subJson["landmark_name"].stringValue, latitude: subJson["landmark_latitude"].doubleValue, longitude: subJson["landmark_longitude"].doubleValue, description: subJson["landmark_description"].stringValue))
                    }
                }
            }
        }
        
        dataTask?.resume()
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
            vc?.desiredRoute = self.desiredRoute
        }
    }
    
    
    
    
}
