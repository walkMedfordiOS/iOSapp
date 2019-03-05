//
//  Event.swift
//  walkMedfordiOS
//
//  Created by Sam Hollingsworth on 3/4/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import Foundation

class Event {
    let title: String
    let startTime: Int
    let endTime: Int
    let landmarkID: Int
    let description: String
    
    init(title: String, startTime: Int, endTime: Int, landmarkID: Int, description: String) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.landmarkID = landmarkID
        self.description = description
    }
}
