//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/13/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

// MARK: - FlickrClient (Constants)

extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Search Photos
        static let PhotosSearch = "flickr.photos.search"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let Method = "method"
        static let APIKey = "api_key"
        static let SafeSearch = "safe_search"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        
        static let APIKey = "YOUR API KEY HERE"
        static let SafeSearch = "1"
        static let Radius = "5"
        static let Extras = "url_m"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        
    }
    
    // MARK: Response Keys
    struct ResponseKeys {
        
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Pages = "pages"
        static let PerPage = "perpage"
        static let Id = "id"
        static let MediumURL = "url_m"
    }
    
    // MARK: Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}
