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
    
    // Variables for input information
    @IBOutlet weak var routeName: UITextField!
    @IBOutlet weak var routeDescription: UITextField!
    @IBOutlet weak var landmarksTable: UITableView!
    var landmarks = [Landmark]()
    var images = [UIImage]()
    
    // Variables to show errors
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
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
            
        }
    }
    
    /*
     Purpose: To create a route if all fields are completed
     Notes:
     */
    @IBAction func createRoute(_ sender: Any) {
        
        if (allFieldsFilled()) {
            print("Creating Route")
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
    
}
