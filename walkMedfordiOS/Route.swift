//
//  Route.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 2/23/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//
import Foundation
import MapKit

class Route {
    let id: Int
    let name: String
    let description: String
    var landmarks: [Landmark] = [Landmark]()
    
    init(id: Int, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}
