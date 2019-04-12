//
//  RouteCreationView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/3/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import UIKit

class RouteCreationView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Variables for input information
    @IBOutlet weak var routeName: UITextField!
    @IBOutlet weak var routeDescription: UITextField!
    @IBOutlet weak var landmarksTable: UITableView!
    var landmarks = [Landmark]()
    var images = [UIImage]()
    var route_id = 0
    var landmark_ids = [Int]()
    var stop_ids = [Int]()
    
    // Variables to show errors
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Variables to edit landmark
    var editLandmark: Landmark!
    var editImage: UIImage!
    var editIndex: Int!
    
    /*
     Purpose: To load the variables initially
     Notes:
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        // Set variables for landmarks tables
        landmarksTable.dataSource = self
        landmarksTable.allowsSelection = true
        landmarksTable.delegate = self
    }
    
    /*
     Purpose: To reload the table once a new landmark is added
     Notes:
     */
    override func viewWillAppear(_ animated: Bool) {
        landmarksTable.reloadData()
    }
    
    /*
     Purpose: To cancel route creation
     Notes:
     */
    @IBAction func cancelRouteCreation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        
        return landmarks.count
    }
    
    /*
     Purpose: To populate the table with routes and their descriptions
     Notes:
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        if (tableView == landmarksTable) {
            cell!.textLabel?.text = landmarks[indexPath.row].title
            cell!.detailTextLabel?.text = landmarks[indexPath.row].description
        }
        
        return cell!
    }
    
    /*
     Purpose: To go to landmark creation page if one landmark is chosen to be edited
     Notes:
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == landmarksTable) {
            editLandmark = landmarks[indexPath.row]
            editImage = images[indexPath.row]
            editIndex = indexPath.row
            performSegue(withIdentifier: "segueEditLandmark", sender: self)
        }
    }

    /*
     Purpose: To pass landmark to next view to be edited
     Notes:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueEditLandmark") {
            if let destinationVC = segue.destination as? LandmarkCreationView {
                destinationVC.editLandmark = editLandmark
                destinationVC.editImage = editImage
                destinationVC.editIndex = editIndex
            }
        }
    }
    
    /*
     Purpose: To create a route if all fields are completed
     Notes:
     */
    @IBAction func createRoute(_ sender: Any) {
        
        if (allFieldsFilled()) {
            print("Creating Route")
            
            sendRoute()
        } else {
            errorView.isHidden = false
        }
    }
    
    /*
     Purpose: To check if all fields are filled
     Notes:
     */
    func allFieldsFilled() -> Bool {
        var filled = true
        errorLabel.text = ""
        
        if (routeName.text == "") {
            print("Route Name Required")
            errorLabel.text = errorLabel.text! + "Route Name Required \n"
            filled = false
        }
        
        if (routeDescription.text == "") {
            print("Route Description Required")
            errorLabel.text = errorLabel.text! + "Route Description Required \n"
            filled = false
        }
        
        if (landmarks.count < 2) {
            print("Not Enough Landmarks in Route")
            errorLabel.text = errorLabel.text! + "Not Enough Landmarks in Route \n"
            filled = false
        }
        
        if (landmarks.count != images.count) {
            print("Unequal number of landmarks and landmark images")
            errorLabel.text = errorLabel.text! + "Unequal number of landmarks and landmark images \n"
            filled = false
        }
        
        return filled
    }
    
    /*
     Purpose: To close errorView
     Notes:
     */
    @IBAction func cancelErrorView(_ sender: Any) {
        errorView.isHidden = true
    }
    
    /*
     Purpose: To send the route to the database
     Notes:
     */
    func sendRoute() {
        let name = routeName.text!
        let description = routeDescription.text!
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/createRoute") {
            urlComponents.query = "name=\(name)&description=\(description)"
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let json = JSON(data)
                    
                    self.route_id = json["route_id"].intValue
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To send the landmarks to the database
     Notes:
     */
    func sendLandmarks() {
        
        for landmark in landmarks {
            
            dataTask?.cancel()
            
            let name = landmark.title
            let latitude = landmark.location.latitude
            let longitude = landmark.location.longitude
            let address = landmark.address
            let description = landmark.description
            
            if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/createRoute") {
                urlComponents.query = "name=\(name)&latitude=\(latitude)&longitude=\(longitude)&address=\(address)&description=\(description)"
                
                guard let url = urlComponents.url else { return }
                dataTask = defaultSession.dataTask(with: url) { data, response, error in
                    defer { self.dataTask = nil }
                    
                    if let error = error {
                        print("DataTask error: " + error.localizedDescription + "\n")
                    } else if let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200 {
                        
                        let json = JSON(data)
                        
                        self.landmark_ids.append(json["landmark_id"].intValue)
                    }
                }
            }
            
            dataTask?.resume()
        }
        
        sendStops()
    }
    
    /*
     Purpose: To send the stops to the database
     Notes:
     */
    func sendStops() {
        var stop_number = 1
        
        for landmark in landmark_ids {
            
            dataTask?.cancel()
            
            let landmark_id = landmark + 1
            
            if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/createRoute") {
                urlComponents.query = "landmark_id=\(landmark_id)&route_id=\(route_id)&stop_number=\(stop_number)"
                
                guard let url = urlComponents.url else { return }
                dataTask = defaultSession.dataTask(with: url) { data, response, error in
                    defer { self.dataTask = nil }
                    
                    if let error = error {
                        print("DataTask error: " + error.localizedDescription + "\n")
                    } else if let data = data,
                        let response = response as? HTTPURLResponse,
                        response.statusCode == 200 {
                        
                        let json = JSON(data)
                        
                        self.stop_ids.append(json["stop_id"].intValue)
                    }
                }
            }
            
            dataTask?.resume()
            
            stop_number += 1
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            landmarks.remove(at: indexPath.row)
            images.remove(at: indexPath.row)
            landmarksTable.reloadData()
        }
    }
}
