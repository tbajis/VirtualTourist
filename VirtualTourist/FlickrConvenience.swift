//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/13/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import Foundation

// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    func getPhotosUsingFlickr(_ pin: Pin?, completionHandlerForGetPhotosUsingFlickr: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard pin != nil else {
            print("Could not acquire pin value for photo search")
            completionHandlerForGetPhotosUsingFlickr(false, "Could not complete photo searh with pin")
            return
        }
        
        /* 1. Specify the parameters */
        let parameters: [String:AnyObject]? = [
            FlickrClient.ParameterKeys.Method: FlickrClient.Methods.PhotosSearch as AnyObject,
            FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.APIKey as AnyObject,
            FlickrClient.ParameterKeys.SafeSearch: FlickrClient.ParameterValues.SafeSearch as AnyObject,
            FlickrClient.ParameterKeys.Latitude: pin?.latitude as AnyObject,
            FlickrClient.ParameterKeys.Longitude: pin?.longitude as AnyObject,
            FlickrClient.ParameterKeys.Radius: FlickrClient.ParameterValues.Radius as AnyObject,
            FlickrClient.ParameterKeys.Extras: FlickrClient.ParameterValues.Extras as AnyObject,
            FlickrClient.ParameterKeys.NoJSONCallback: FlickrClient.ParameterValues.DisableJSONCallback as AnyObject
        ]
    
        /* 2. Make the request */
        let _ = taskForGETMethod(parameters: parameters!) { (results, error) in
        
            /* 3. Send the desired values to the completion handler */
            guard (error == nil) else {
                print("There was an error in getFlickrPhotos")
                completionHandlerForGetPhotosUsingFlickr(false, error)
                return
            }
            guard let status = results?[FlickrClient.ResponseKeys.Status] as? String, status == "ok" else {
                print("There was a status error in getFlickrPhotos")
                completionHandlerForGetPhotosUsingFlickr(false, "Response returned a bad status code!")
                return
            }
            guard let photosDictionary = results?[FlickrClient.ResponseKeys.Photos] as? [String:AnyObject], let photoArrayOfDictionaries = photosDictionary[FlickrClient.ResponseKeys.Photo] as? [[String:AnyObject]] else {
                print("There was an error parsing photos")
                completionHandlerForGetPhotosUsingFlickr(false, "Could not load photos from Flickr!")
                return
            }
            print("Successfully parsed photos!")
            for photoDictionary in photoArrayOfDictionaries {
                let photo = Photo(dictionary: photoDictionary, context: AppDelegate.stack.context)
                photo.pin = pin
            }
            completionHandlerForGetPhotosUsingFlickr(true, nil)
        }
    }
}
