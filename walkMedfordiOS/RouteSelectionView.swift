//
//  RouteSelectionView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 11/26/18.
//  Copyright © 2018 walkMedford. All rights reserved.
//
import UIKit
import CoreLocation

class RouteSelectionView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Variables for selected route
    var routes = [Route]()
    var desiredRoute = Route(id: 0, name: "", description: "")
    
    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Variables for table
    @IBOutlet weak var routeTable: UITableView!
    
    /*
     Purpose: To call any functions when view is loaded
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set variables for routeTable
        routeTable.dataSource = self
        routeTable.allowsSelection = true
        routeTable.delegate = self
        
        getAllRoutes()
    }
    
    /*
     Purpose: To get all the walking routes
     Notes:
     */
    func getAllRoutes() {
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
                }
                
                DispatchQueue.main.async {
                    self.routeTable.reloadData()
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To specify the number of sections in the table
     Notes:
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     Purpose: To specify the number of rows in the table
     Notes:
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    /*
     Purpose: To populate the table with routes and their descriptions
     Notes:
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.textLabel?.text = routes[indexPath.row].name
        cell!.detailTextLabel?.text = routes[indexPath.row].description
        
        return cell!
    }
    
    /*
     Purpose: To set desiredRoute when a route is chosen
     Notes:
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.desiredRoute = routes[indexPath.row]
        
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
                            Landmark(title: subJson["landmark_name"].stringValue,
                                     latitude: subJson["landmark_latitude"].doubleValue,
                                     longitude: subJson["landmark_longitude"].doubleValue,
                                     address: subJson["landmark_address"].stringValue,
                                     description: subJson["landmark_description"].stringValue))
                    }
                    
                    DispatchQueue.main.async {
                        self.returnToMap()
                    }
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To return to MapView
     Notes:
     */
    func returnToMap() {
        
        let vc = self.tabBarController?.viewControllers?[0] as! MapView
        vc.desiredRoute = desiredRoute
        tabBarController?.selectedIndex = 0
    }
}
