//
//  User.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 2/28/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//
import Foundation

class User {
    let id: Int
    let username: String
    let admin: Bool
    
    init(id: Int, username: String, admin: Bool) {
        self.id = id
        self.username = username
        self.admin = admin
    }
}
