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
    
    // Variables for Events and Landmarks
    var events = [Event]()
    var landmarks = [Landmark]()
    
    // Vraiables for Tables
    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var landmarksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set variables for events and landmarks tables
        eventsTable.dataSource = self
        eventsTable.allowsSelection = true
        eventsTable.delegate = self
        landmarksTable.dataSource = self
        landmarksTable.allowsSelection = true
        landmarksTable.delegate = self
        
        getAllEvents()
    }
    
    /*
     Purpose: To get all the events
     Notes:
     */
    func getAllEvents() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/allEvents") {
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
                    
                    // Adds events to array of type Event
                    for (_,subJson):(String, JSON) in json {
                        let newEvent = Event(title: subJson["event_title"].stringValue,
                                             startTime: subJson["start_time"].intValue,
                                             endTime: subJson["end_time"].intValue,
                                             landmarkID: subJson["landmark_id"].intValue,
                                             description: subJson["event_description"].stringValue)
                        self.events.append(newEvent)
                    }

                    if (self.events.count == 0) {
                        self.events.append(Event(title: "No events are currently posted", startTime: 0, endTime: 0, landmarkID: 0, description: ""))
                    }
                }
                
                DispatchQueue.main.async {
                    self.eventsTable.reloadData()
                    self.getAllLandmarks()
                }
            }
        }
        
        dataTask?.resume()
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
        if tableView == eventsTable {
            return events.count
        } else {
            return landmarks.count
        }
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
        
        if (tableView == eventsTable) {
            cell!.textLabel?.text = events[indexPath.row].title
            cell!.detailTextLabel?.text = events[indexPath.row].description
        } else {
            cell!.textLabel?.text = landmarks[indexPath.row].title
            cell!.detailTextLabel?.text = landmarks[indexPath.row].description
        }
        
        return cell!
    }
    
    /*
     Purpose: To show landmark information when a landmark is chosen
     Notes:
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == landmarksTable) {
            let vc = LandmarkView()
            vc.landmark = landmarks[indexPath.row]
            print(landmarks[indexPath.row].title)
            print(vc.landmark!.title)
            present(vc, animated: true)
        }
    }

}
