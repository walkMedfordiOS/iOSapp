//
//  Landmark.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 2/18/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//
import Foundation
import MapKit

class Landmark {
    let id: Int
    let title: String
    let location: CLLocationCoordinate2D
    let address: String
    let description: String
    
    init(id: Int, title: String, latitude: Double, longitude: Double, address: String, description: String) {
        self.id = id
        self.title = title
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.address = address
        self.description = description
    }
}
