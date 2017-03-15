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
        static let ApiPath = "/services/rest"
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
        static let Extras = "extras"
        static let Format = "format"
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        
        static let APIKey = "8aa6a4f5de5502cef8f33144d857035f"
        static let ResponseFormat = "json"
        static let MediumURL = "url_m"
        
    }
    
    // MARK: Response Keys
    struct ResponseKeys {
        
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
    }
    
    // MARK: Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}
