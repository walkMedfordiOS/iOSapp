//
//  Total+CoreDataProperties.swift
//  walkMedfordiOS
//
//  Created by user150397 on 4/4/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//
//

import Foundation
import CoreData


extension Total {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Total> {
        return NSFetchRequest<Total>(entityName: "Total")
    }

    @NSManaged public var steps: Double
    @NSManaged public var calories: Double

}
