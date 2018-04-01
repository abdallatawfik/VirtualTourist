//
//  Model.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/9/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import UIKit
import CoreData

class Model {
    
    // MARK: - Properties
    
    let coreDataStack = CoreDataStack(modelName: CoreDataConstants.ModelName)!
    
    // MARK: - Pins Management
    
    func addPinFor(latitude:Double, longitude:Double) {
        let _ = Pin(latitude: latitude, longitude: longitude, context: coreDataStack.context)
        try? coreDataStack.saveContext()
    }
    
    func getPinFor(latitude:Double, longitude:Double) -> Pin? {
        return getPins(predicate: NSPredicate(format: "\(CoreDataConstants.LatitudeAttributeName) == %lf AND \(CoreDataConstants.LongituteAttributeName) == %lf", latitude, longitude))?.first
    }
    
    func getSavedPins() -> [Pin]? {
        return getPins(predicate: nil)
    }
    
    private func getPins(predicate:NSPredicate?) -> [Pin]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.PinEntityName)
        fetchRequest.predicate = predicate
        
        var fetchedPins:[Pin]?
        do {
            fetchedPins = try coreDataStack.context.fetch(fetchRequest) as? [Pin]
        } catch {
            fatalError("Failed to fetch Pins: \(error)")
        }
        
        return fetchedPins
    }
    
    // MARK: - Photos Management
    
    // Checks if a pin already has photos, if not then it downloads photos metadata and add them to the pin
    func checkPhotosFor(pin:Pin, completionHandler:@escaping (_ photosCollectionFound:Bool) -> Void) {
        // If the pin already has photos
        if pin.photos!.count > 0 {
            completionHandler(true)
        } else {
            FlickrClient.sharedInstance().getPhotosUrlFor(latitude: pin.latitude, longitude: pin.longitude) { (photosUrl) in
                DispatchQueue.main.async {
                    if photosUrl.count > 0 {
                        var index = 0
                        for photoUrl in photosUrl {
                            let photo = Photo(id: index, imageUrl: photoUrl, context: self.coreDataStack.context)
                            photo.pin = pin
                            index += 1
                        }
                        
                        try? self.coreDataStack.saveContext()
                        
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
            }
        }
        
    }
    
    // Deletes the old photos collection and request a new one
    func getNewCollectionFor(pin:Pin, completionHandler:@escaping (_ newCollectionFound:Bool) -> Void) {
        deletePhotosFor(pin: pin)
        checkPhotosFor(pin: pin) { (success) in
            completionHandler(success)
        }
    }
    
    func getPhotosFor(pin:Pin) -> [Photo] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.PhotoEntityName)
        fetchRequest.predicate = NSPredicate(format: "\(CoreDataConstants.PinAttributeName) == %@", pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataConstants.IDAttributeName, ascending: true)]
        
        var photos = [Photo]()
        do {
            photos = try coreDataStack.context.fetch(fetchRequest) as! [Photo]
        } catch {
            fatalError("Failed to fetch Photos: \(error)")
        }
        
        return photos
    }
    
    func getImagefor(photo:Photo, completionHandler: @escaping (_ image:UIImage) -> Void) {
        if let imageData = photo.imageData as Data?, let image = UIImage(data: imageData) {
            completionHandler(image)
        } else {
            FlickrClient.sharedInstance().downloadImageWith(url: URL(string: photo.imageUrl!)!) { (imageData) in
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        photo.imageData = imageData as NSData
                    }
                    completionHandler(image)
                }
            }
        }
    }
    
    // Photos Deletion
    
    private func deletePhotosFor(pin:Pin) {
        if let photos = pin.photos?.allObjects as? [Photo] {
            for photo in photos {
                deletePhoto(photo: photo)
            }
            try? coreDataStack.saveContext()
        }
    }
    
    func deletePhoto(photo:Photo) {
        coreDataStack.context.delete(photo)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}
