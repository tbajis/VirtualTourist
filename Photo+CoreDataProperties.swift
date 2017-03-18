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

    struct Constants {
        static let MediaURL = FlickrClient.ResponseKeys.MediumURL
        static let Id = FlickrClient.ResponseKeys.Id
    }
    
    @NSManaged var image: Data?
    @NSManaged var mediaURL: String?
    @NSManaged var id: String?
    @NSManaged var pin: Pin?
}
