//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/14/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: NSSet?

}
