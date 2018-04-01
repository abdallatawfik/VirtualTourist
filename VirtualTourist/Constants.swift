//
//  Constants.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/6/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import Foundation

// MARK: - Flickr Client Constants

extension FlickrClient {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        // Flickr will return at most the first 4,000 results
        static let MaxUniquePhoto = 4000
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Page = "page"
        static let Latitude = "lat"
        static let Longtude = "lon"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "55832c153d264ed3b94cd752f16994e0"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PerPage = 15 /* This is the maximum number of photos per collection */
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
        static let Pages = "pages"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}

// MARK: - CoreData Constants

struct CoreDataConstants {
    
    // MARK: Model Name
    static let ModelName = "Model"
    
    // MARK: Entities Name
    static let PinEntityName = "Pin"
    static let PhotoEntityName = "Photo"
    
    // MARK: Attributes Name
    static let PinAttributeName = "pin"
    static let LatitudeAttributeName = "latitude"
    static let LongituteAttributeName = "longitude"
    static let IDAttributeName = "id"
}

// MARK: - TravelLocationsMapViewController Constants

extension TravelLocationsMapViewController {
    
    // MARK: Segue Identifiers
    struct SegueIdentifiers {
        static let ToPhotoAlbumViewController = "ShowPhotoAlbum"
    }
    
    // MARK: Reuse Identifiers
    struct ReuseIdentifiers {
        static let AnnotationView = "pin"
    }
    
    // MARK: Region Keys
    struct RegionKeys {
        static let Region = "Region"
        static let CenterLatitude = "CenterLatitude"
        static let CenterLongitude = "CenterLongitude"
        static let SpanLatitudeDelta = "SpanLatitudeDelta"
        static let SpanLongitudeDelta = "SpanLongitudeDelta"
    }
}

// MARK: - PhotoAlbumViewController Constants

extension PhotoAlbumViewController {
    
    // MARK: General Constants
    static let BackButtonTitle = "Ok"
    
    // MARK: Collection View Constants
    struct CollectionViewConstants {
        static let CellReuseIdentifier = "AlbumCell"
        static let CellPlaceholderImageName = "placeholder"
    }
    
    // MARK: Alerts
    struct Alerts {
        // Messages
        static let RemoveImageMessage = "Are you sure you want to remove this image?"
        
        // Actions
        static let ConfirmRemovingImage = "Yes"
        static let CancelRemovingImage = "Cancel"
    }
}



