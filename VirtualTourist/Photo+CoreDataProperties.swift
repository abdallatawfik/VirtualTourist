//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/12/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var id: Int32
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
