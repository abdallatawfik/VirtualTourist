//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/6/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import UIKit

// MARK: - Flicker Client

class FlickrClient {

    // Generic http GET Request
    
    // Make, start and return a network task according to the given parameters.
    fileprivate func performTaskForUrl(url:URL, parseJSON:Bool, completionHandler:@escaping (_ result:AnyObject?, _ error:String?) -> Void) {
        // Configure the request
        let request = URLRequest(url: url)
        
        // Make the network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                completionHandler(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if parseJSON {
                // Parse the data
                let parsedResult: AnyObject
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                } catch {
                    sendError("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                completionHandler(parsedResult, nil)
            }
            else {
                completionHandler(data as AnyObject?, nil)
            }
        }
        
        // Start the network task
        task.resume()
    }

    // MARK: Helper for Creating a URL from Parameters

    fileprivate func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}


// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    // Downloads a random collection of photos taken around the passed location (default radius of 5 km)
    func getPhotosUrlFor(latitude:Double, longitude:Double, completionHandler:@escaping (_ photosUrl:[String]) -> Void) {
        func getPhotosMetadataFor(page:Int, handler:@escaping (_ photosDictionary:[String:AnyObject]?, _ error:String?) -> Void) {
            let methodParameters = [
                FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
                FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
                FlickrParameterKeys.Latitude: "\(latitude)",
                FlickrParameterKeys.Longtude: "\(longitude)",
                FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
                FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
                FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
                FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
                FlickrParameterKeys.PerPage: "\(FlickrParameterValues.PerPage)",
                FlickrParameterKeys.Page: "\(page)"
            ]
            
            performTaskForUrl(url: flickrURLFromParameters(methodParameters as [String : AnyObject]), parseJSON: true) { (result, error) in
                
                func sendError(_ error: String) {
                    print(error)
                    handler(nil, error)
                }
                
                guard error == nil else {
                    sendError(error!)
                    return
                }
                
                if let result = result as? [String:AnyObject] {
                    
                    /* GUARD: Did Flickr return an error (stat != ok)? */
                    guard let stat = result[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                        sendError("Flickr API returned an error. See error code and message in \(result)")
                        return
                    }
                    
                    /* GUARD: Is "photos" key in our result? */
                    guard let photosDictionary = result[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                        sendError("Cannot find keys '\(FlickrResponseKeys.Photos)' in \(result)")
                        return
                    }
                    
                    handler(photosDictionary, nil)
                }
            }
        }
        
        func getPhotosUrl(from photosDictionary:[String:AnyObject]) -> [String] {
            var photosUrl = [String]()
            
            if let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                for photoDictionary in photosArray {
                    photosUrl.append(photoDictionary[FlickrResponseKeys.MediumURL] as! String)
                }
            }
            
            return photosUrl
        }
        
        getPhotosMetadataFor(page: 1) { (photosDictionary, error) in
            guard error == nil else {
                // Handle the error...
                return
            }
            
            if let photosDictionary = photosDictionary {
                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let totalPages = photosDictionary[FlickrResponseKeys.Pages] as? Int else {
                    print("Cannot find key '\(FlickrResponseKeys.Pages)' in \(photosDictionary)")
                    return
                }
                // Pick a random page
                if totalPages > 1 {
                    let pageLimit = min(totalPages, Flickr.MaxUniquePhoto/FlickrParameterValues.PerPage)
                    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                    
                    getPhotosMetadataFor(page: randomPage, handler: { (photosDictionary, error) in
                        guard error == nil else {
                            // Handle the error...
                            return
                        }
                        
                        if let photosDictionary = photosDictionary {
                            completionHandler(getPhotosUrl(from: photosDictionary))
                        }
                    })
                } else {
                    completionHandler(getPhotosUrl(from: photosDictionary))
                }
            }
        }
    }
    
    // Downloads imageData from the passed url
    func downloadImageWith(url: URL, completionHandler:@escaping (_ imageData:Data) -> Void) {
        performTaskForUrl(url: url, parseJSON: false) { (result, error) in
            
            guard error == nil else {
                // Handle the error...
                return
            }
            
            if let imageData = result as? Data {
                completionHandler(imageData)
            }
        }
    }
}
