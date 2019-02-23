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
    let name: String
    let description: String
    let landmarks: [Landmark] = [Landmark]()
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}
