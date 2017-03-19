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
        
        var pageNumber: Int?
        var photosPerPage: Int?
        guard pin != nil else {
            print("Could not acquire pin value for photo search")
            completionHandlerForGetPhotosUsingFlickr(false, "Could not complete photo searh with pin")
            return
        }
        
        /* 1. Specify the parameters */
        var parameters: [String:AnyObject]? = [
            FlickrClient.ParameterKeys.Method: FlickrClient.Methods.PhotosSearch as AnyObject,
            FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.APIKey as AnyObject,
            FlickrClient.ParameterKeys.SafeSearch: FlickrClient.ParameterValues.SafeSearch as AnyObject,
            FlickrClient.ParameterKeys.Latitude: pin?.coordinate.latitude as AnyObject,
            FlickrClient.ParameterKeys.Longitude: pin?.coordinate.longitude as AnyObject,
            FlickrClient.ParameterKeys.Radius: FlickrClient.ParameterValues.Radius as AnyObject,
            FlickrClient.ParameterKeys.Extras: FlickrClient.ParameterValues.Extras as AnyObject,
            FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.ResponseFormat as AnyObject,
            FlickrClient.ParameterKeys.NoJSONCallback: FlickrClient.ParameterValues.DisableJSONCallback as AnyObject
        ]
    
        randomPageFromSearch(parameters: parameters) { (randomPage, perPage) in
            pageNumber = randomPage
            photosPerPage = perPage
            
        
            parameters?[FlickrClient.ParameterKeys.Page] = pageNumber as AnyObject?
            parameters?[FlickrClient.ParameterKeys.PerPage] = photosPerPage as AnyObject?
            print(parameters!)
            print(pageNumber!)
            print(perPage)
            /* 2. Make the request */
            let _ = self.taskForGETMethod(parameters: parameters!) { (results, error) in
        
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
    
    private func randomPageFromSearch(parameters: [String:AnyObject]?, completionHandlerForRandomPageFromSearch: @escaping (_ randomPage: Int, _ photosPerPage: Int) -> Void) {
        
        var numberOfPagesFromRequest: Int?
        var totalNumberOfPages: Int?
        
        let _ = taskForGETMethod(parameters: parameters!) { (results, error) in
            
            /* 3. Send the desired values to the completion handler */
            guard (error == nil) else {
                print("There was an error in getFlickrPhotos")
                return
            }
            guard let status = results?[FlickrClient.ResponseKeys.Status] as? String, status == "ok" else {
                print("There was a status error in getFlickrPhotos")
                return
            }
            guard let photosDictionary = results?[FlickrClient.ResponseKeys.Photos] as? [String:AnyObject], let numberOfPages = photosDictionary[FlickrClient.ResponseKeys.Pages] as? Int, let totalPerPage = photosDictionary[FlickrClient.ResponseKeys.PerPage] as? Int else {
                print("There was an error parsing photos for page number")
                return
            }
            numberOfPagesFromRequest = numberOfPages
            totalNumberOfPages = Int(totalPerPage)
            let numberOfPhotos = min(totalNumberOfPages!, 21)
            let pageLimit = min(numberOfPagesFromRequest!, 50)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            completionHandlerForRandomPageFromSearch(randomPage, numberOfPhotos)
        }
    }
}
