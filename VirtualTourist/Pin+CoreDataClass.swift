//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/12/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(latitude:Double, longitude:Double, context:NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: CoreDataConstants.PinEntityName, in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude            
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
}
