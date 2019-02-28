//
//  SignUpView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 2/28/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import UIKit

class SignUpView: UIViewController {
    
    // Variable for user
    var user: User?
    
    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Variables for user's credentials
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmedPasswordTextField: UITextField!
    
    // Variable for warning if credentials are incorrect
    @IBOutlet weak var incorrectUsernameLabel: UILabel!
    @IBOutlet weak var incorrectPasswordsLabel: UILabel!
    
    /*
    Purpose: To check if username is available then create account if so
    Notes:
    */
    @IBAction func createAccount(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        let confirmedPassword = confirmedPasswordTextField.text
        
        if (password != confirmedPassword) {
            incorrectPasswords()
        }
        
        checkUsername(username: username!, password: password!)
    }
    
    /*
     Purpose: To warn user if passwords are different
     Notes:
     */
    func incorrectPasswords() {
        incorrectPasswordsLabel.text = "Passwords do not match"
    }
    
    /*
     Purpose: To warn user if username is already taken
     Notes:
     */
    func incorrectUsername() {
        incorrectUsernameLabel.text = "Username is already taken"
    }
    
    /*
     Purpose: To check if username is available
     Notes:
     */
    func checkUsername(username: String, password: String) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/usernameAvailable") {
            urlComponents.query = "username=\(username)"
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let json = JSON(data)
                    
                    if (json.boolValue) {
                        DispatchQueue.main.async {
                            self.addUser(username: username, password: password)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.incorrectUsername()
                        }
                    }
                    
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To add account to database
     Notes:
     */
    func addUser(username: String, password: String) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/usernameAvailable") {
            urlComponents.query = "username=\(username)&password=\(password)"
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let _ = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    DispatchQueue.main.async {
                        self.loginUser(username: username, password: password)
                    }
                    
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To set the user variable
     Notes:
     */
    func loginUser(username: String, password: String) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://walkmedford.herokuapp.com/loginUser") {
            urlComponents.query = "username=\(username)&password=\(password)"
            
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let json = JSON(data)
                    
                    // If user credentials are correct or not
                    if (json.isEmpty) {
                        // Do something
                    } else {
                        self.user = User(id: json["user_id"].intValue, username: json["username"].stringValue, admin: json["admin"].boolValue)
                        
                        DispatchQueue.main.async {
                            self.toMapView()
                        }
                    }
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To proceed to map view
     Notes:
     */
    func toMapView() {
        let vc = MapView()
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
