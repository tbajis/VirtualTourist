//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/14/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @NSManaged var image: NSData?
    @NSManaged var mediaURL: String?
    @NSManaged var id: String?
    @NSManaged var pin: Pin?

}
