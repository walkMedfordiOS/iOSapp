//
//  LoginView.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 2/28/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//
import UIKit

class LoginView: UIViewController {
    
    // Variable for user
    var user: User?
    
    // Variables for HTTP Requests
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    // Variables for username and password fields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Variable for incorrect username/password label
    @IBOutlet weak var incorrectLabel: UILabel!
    
    /*
     Purpose: To check if the user's credentials are correct
     Notes:
     */
    @IBAction func loginUser(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        checkUser(username: username!, password: password!)
    }
    
    /*
     Purpose: To send the username and password to the database to check
     Notes:
     */
    func checkUser(username: String, password: String) {
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
                        DispatchQueue.main.async {
                            self.incorrectCredentials()
                        }
                    } else {
                        self.user = User(id: json["user_id"].intValue, username: json["username"].stringValue, admin: json["admin"].boolValue)
        
                        DispatchQueue.main.async {
                            self.correctCredentials()
                        }
                    }
                }
            }
        }
        
        dataTask?.resume()
    }
    
    /*
     Purpose: To alert the user the username & password combination is incorrect
     Notes:
     */
    func incorrectCredentials() {
        incorrectLabel.text = "Username or password is incorrect"
    }
    
    /*
     Purpose: To pass the user along to MapView
     Notes:
     */
    func correctCredentials() {
        let vc = MapView()
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
