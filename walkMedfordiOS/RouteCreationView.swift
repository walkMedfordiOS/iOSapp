//
//  RouteCreationView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/3/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class RouteCreationView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
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
     Purpose: To hide the keyboard when the return key is pressed
     Notes:
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == routeName) {
            routeName.resignFirstResponder()
            routeDescription.becomeFirstResponder()
        } else if (textField == routeDescription) {
            textField.resignFirstResponder()
        }
        
        return true
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
            sendImages()
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
        
        if (landmarks.count < 1) {
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
                    
                    for (_,subJson):(String, JSON) in json {
                        self.route_id = subJson["route_id"].intValue
                        print("Route ID: \(subJson["route_id"].intValue)")
                    }
                    
                    self.sendLandmarks(landmarkNum: 0)
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To send the landmarks to the database
     Notes:
     */
    func sendLandmarks(landmarkNum: Int) {
        
        dataTask?.cancel()
            
        let name = landmarks[landmarkNum].title
        let latitude = landmarks[landmarkNum].location.latitude
        let longitude = landmarks[landmarkNum].location.longitude
        let address = landmarks[landmarkNum].address
        let description = landmarks[landmarkNum].description
    
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/createLandmark") {
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
                        
                    for (_,subJson):(String, JSON) in json {
                        self.landmark_ids.append(subJson["landmark_id"].intValue)
                        print("Landmark ID: \(subJson["landmark_id"].intValue)")
                    }
                    
                    if (landmarkNum + 1 < self.landmarks.count) {
                        self.sendLandmarks(landmarkNum: landmarkNum + 1)
                    } else {
                        self.sendStops(landmarkNum: 0, stop: 1)
                    }
                }
            }
        }
            
        dataTask?.resume()
    }
    
    /*
     Purpose: To send the stops to the database
     Notes:
     */
    func sendStops(landmarkNum: Int, stop: Int) {
        
        dataTask?.cancel()
            
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/createStop") {
            urlComponents.query = "landmark_id=\(landmark_ids[landmarkNum])&route_id=\(route_id)&stop_number=\(stop)"
            
            print("Sending stop, landmark_id: \(landmark_ids[landmarkNum]), route_id: \(route_id), stop: \(stop)")
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                    
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let json = JSON(data)
                    
                    
                    for (_,subJson):(String, JSON) in json {
                        self.stop_ids.append(subJson["stop_id"].intValue)
                        print("Stop ID: \(subJson["stop_id"].intValue)")
                    }
                    
                    if (landmarkNum + 1 < self.landmark_ids.count) {
                        self.sendStops(landmarkNum: landmarkNum + 1, stop: stop + 1)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
            
        dataTask?.resume()
    }
    
    /*
     Purpose: To send all images to Firebase Storage
     Notes:
     */
    func sendImages() {
    
        for (index, image) in images.enumerated() {
        
            var filename = landmarks[index].title.replacingOccurrences(of: " ", with: "_")
            filename = filename.replacingOccurrences(of: "/", with: "_")
            filename = filename.replacingOccurrences(of: "\\", with: "_")
            filename = filename.replacingOccurrences(of: ":", with: "_")
            filename = filename.replacingOccurrences(of: ",", with: "_")
            filename += ".jpg"
        
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
        
            let imagesRef = storageRef.child(filename)
            let data: NSData = image.jpegData(compressionQuality: 1)! as NSData
        
            imagesRef.putData(data as Data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    print("ERROR")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                print(size)
            }
        }
    }
    
    /*
     Purpose: To allow the user to delete a row
     Notes:
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    /*
     Purpose: To allow the user to delete a row
     Notes:
     */
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
