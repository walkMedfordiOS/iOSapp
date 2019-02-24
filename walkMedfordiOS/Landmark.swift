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
    let title: String
    let location: CLLocationCoordinate2D
    let description: String
    
    init(title: String, latitude: Double, longitude: Double, description: String) {
        self.title = title
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.description = description
    }
}
