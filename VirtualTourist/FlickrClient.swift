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
    
    // Shared session
    var session = URLSession.shared
    
    // MARK: GET
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: [String:AnyObject]?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let parametersForRequest = parameters
        
        /* 2/3. Buld the URL, Configure the request */
        let request = NSMutableURLRequest(url: flickrURLBuilder(parametersForRequest, withPathExtension: nil))
        print(request.url!)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String) {
                print(error)
                completionHandlerForGET(nil, error)
            }
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
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
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertedData: completionHandlerForGET)
        }
        /* 7. Start the task */
        task.resume()
        return task
    }
    
    // Create a url from parameters
    private func flickrURLBuilder(_ parameters: [String:AnyObject], withPathExtension: String?) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
    // Given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ error: String?) -> Void) {
        
        var parsedResult: [String:AnyObject]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
        } catch {
            completionHandlerForConvertedData(nil, "Could not serialize the data from JSON")
            print("Serialization FAILED")
        }
        completionHandlerForConvertedData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
