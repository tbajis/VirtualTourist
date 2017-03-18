//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/14/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    // MARK: Initializers
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        self.id = dictionary[Photo.Constants.Id] as? String
        self.mediaURL = dictionary[Photo.Constants.MediaURL] as? String
        do {
            self.image = try Data(contentsOf: URL(string: mediaURL!)!)
        } catch {
            print("Error creating image data")
        }
    }
}
