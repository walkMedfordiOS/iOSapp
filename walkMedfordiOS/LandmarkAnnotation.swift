//
//  LandmarkAnnotation.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 11/30/18.
//  Copyright © 2018 walkMedford. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var imageName: String? {
        return "landmark"
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return title
    }
}
