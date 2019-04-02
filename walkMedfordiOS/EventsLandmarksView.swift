//
//  EventsLandmarksView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/4/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import UIKit

class EventsLandmarksView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    @IBOutlet weak var webActivity: UIActivityIndicatorView!
    
    // Variables for Events and Landmarks
    var landmarks = [Landmark]()
    var desiredLandmark: Landmark!
    
    // Variable for Table
    @IBOutlet weak var landmarksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set variables for landmarks tables
        landmarksTable.dataSource = self
        landmarksTable.allowsSelection = true
        landmarksTable.delegate = self
        
        webActivity.startAnimating()
        webActivity.hidesWhenStopped = true
    }

    /*
     Purpose: To get all the landmarks
     Notes:
     */
    func getAllLandmarks() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/allLandmarks") {
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
                    
                    // Adds landmarks to array of type Landmark
                    for (_,subJson):(String, JSON) in json {
                        let newLandmark = Landmark(title: subJson["landmark_name"].stringValue,
                                                   latitude: subJson["landmark_latitude"].doubleValue,
                                                   longitude: subJson["landmark_longitude"].doubleValue,
                                                   address: subJson["landmark_address"].stringValue,
                                                   description: subJson["landmark_description"].stringValue)
                        self.landmarks.append(newLandmark)
                    }
                }
                
                DispatchQueue.main.async {
                    self.webActivity.stopAnimating()
                    self.landmarksTable.reloadData()
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
//        if tableView == eventsTable {
//            return events.count
//        }
        
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
        } else {
//            cell!.textLabel?.text = events[indexPath.row].title
//            cell!.detailTextLabel?.text = events[indexPath.row].description
        }
        
        return cell!
    }
    
    /*
     Purpose: To show landmark information when a landmark is chosen
     Notes:
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == landmarksTable) {
            desiredLandmark = landmarks[indexPath.row]
            performSegue(withIdentifier: "segueEventsLandmarksToLandmark", sender: self)
        }
    }
    
    /*
     Purpose: To pass data to next view
     Notes:
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueEventsLandmarksToLandmark") {
            if let destinationVC = segue.destination as? LandmarkView {
                destinationVC.landmark = desiredLandmark
            }
        }
    }

}
