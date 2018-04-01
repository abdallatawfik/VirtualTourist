//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/10/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(id:Int, imageUrl:String, context:NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: CoreDataConstants.PhotoEntityName, in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = Int32(id)
            self.imageUrl = imageUrl
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
