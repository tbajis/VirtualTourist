//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/13/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import Foundation

// MARK: - FlickrClient: NSObject

class FlickrClient: NSObject {
    /*
    // Shared session
    var session = URLSession.shared
    
    // MARK: GET
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: [String:AnyObject], _ error: String?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let parametersForRequest = parameters
        
        /* 2/3. Buld the URL, Configure the request */
    }
    
    // Create a url from parameters
    private func flickrURLBuilder(parameters: [String:AnyObject], withPathExtension: String?) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath + (withPathExtension ?? "")
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
    // Given raw JSON, return a usable Foundation object
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }*/
}
