//
//  StartEndAnnotation.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/26/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class StartEndAnnotation: NSObject, MKAnnotation {
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
}
