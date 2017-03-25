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

    // Get images from urls stored in CoreData, show in photoAlbumCollectionViewController
    func getFlickrImages(_ photo: Photo?, completionHandlerForGetFlickrImages: @escaping (_ success: Bool, _ errorString: String?, _ imageData: Data?) -> Void) -> URLSessionTask {
        
        let flickrURL = photo?.mediaURL
        let requestURL = URL(string: flickrURL!)
        let request = URLRequest(url: requestURL!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                completionHandlerForGetFlickrImages(false, e.localizedDescription, nil)
            } else {
                completionHandlerForGetFlickrImages(true, nil, data)
            }
        }
        task.resume()
        return task
    }
    
    // Get the number of pages and photos per page for a given request with pin
    func getPhotosUsingFlickr(_ pin: Pin?, completionHandlerForGETPhotosUsingFlickr: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard pin != nil else {
            print("Could not acquire pin value for photo search")
            completionHandlerForGETPhotosUsingFlickr(false, "Could not complete photo search with pin")
            return
        }
        
        /* 1. Specify the parameters */
        let parameters: [String:AnyObject]? = [
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
        var numberOfPagesFromRequest: Int?
        var totalNumberOfPages: Int?
        
        /* 2. Make the request */
        let _ = taskForGETMethod(parameters: parameters!) { (results, error) in
            
            /* 3. Send the desired values to the completion handler */
            guard (error == nil) else {
                print("There was an error in getFlickrPhotos")
                completionHandlerForGETPhotosUsingFlickr(false, "An error occured trying to retrieve photos from Flickr!")
                return
            }
            guard let status = results?[FlickrClient.ResponseKeys.Status] as? String, status == FlickrClient.ResponseValues.OKStatus else {
                print("There was a status error in getFlickrPhotos")
                completionHandlerForGETPhotosUsingFlickr(false, "A status code error occured from Flickr!")
                return
            }
            guard let photosDictionary = results?[FlickrClient.ResponseKeys.Photos] as? [String:AnyObject], let numberOfPages = photosDictionary[FlickrClient.ResponseKeys.Pages] as? Int, let totalPerPage = photosDictionary[FlickrClient.ResponseKeys.PerPage] as? Int else {
                print("There was an error parsing photos for page number")
                completionHandlerForGETPhotosUsingFlickr(false, "An error occured downloading photos from Flickr!")
                return
            }
            numberOfPagesFromRequest = numberOfPages
            totalNumberOfPages = Int(totalPerPage)
            let numberOfPhotos = min(totalNumberOfPages!, 21)
            let pageLimit = min(numberOfPagesFromRequest!, 50)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.getPhotosUsingPage(pin, randomPage: randomPage, perPage: numberOfPhotos, completionHandlerForGETPhotosUsingPage: completionHandlerForGETPhotosUsingFlickr)
        }
    }
    
    // Download image data from Flickr by request using pin and a random page number)
    private func getPhotosUsingPage(_ pin: Pin?, randomPage: Int?, perPage: Int?, completionHandlerForGETPhotosUsingPage: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard pin != nil else {
            print("Could not acquire pin value for photo search")
            completionHandlerForGETPhotosUsingPage(false, "Could not complete photo search with page")
            return
        }
        
        /* 1. Specify the parameters */
        let parameters: [String:AnyObject]? = [
            FlickrClient.ParameterKeys.Method: FlickrClient.Methods.PhotosSearch as AnyObject,
            FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.APIKey as AnyObject,
            FlickrClient.ParameterKeys.SafeSearch: FlickrClient.ParameterValues.SafeSearch as AnyObject,
            FlickrClient.ParameterKeys.Latitude: pin?.coordinate.latitude as AnyObject,
            FlickrClient.ParameterKeys.Longitude: pin?.coordinate.longitude as AnyObject,
            FlickrClient.ParameterKeys.Radius: FlickrClient.ParameterValues.Radius as AnyObject,
            FlickrClient.ParameterKeys.Extras: FlickrClient.ParameterValues.Extras as AnyObject,
            FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.ResponseFormat as AnyObject,
            FlickrClient.ParameterKeys.NoJSONCallback: FlickrClient.ParameterValues.DisableJSONCallback as AnyObject,
            FlickrClient.ParameterKeys.Page: randomPage as AnyObject,
            FlickrClient.ParameterKeys.PerPage: perPage as AnyObject
        ]
        
        /* 2. Make the request */
        let _ = self.taskForGETMethod(parameters: parameters!) { (results, error) in
            
            /* 3. Send the desired values to the completion handler */
            guard (error == nil) else {
                print("There was an error in getFlickrPhotos")
                completionHandlerForGETPhotosUsingPage(false, error)
                return
            }
            guard let status = results?[FlickrClient.ResponseKeys.Status] as? String, status == FlickrClient.ResponseValues.OKStatus else {
                print("There was a status error in getFlickrPhotos")
                completionHandlerForGETPhotosUsingPage(false, "A status code error occured from Flickr!")
                return
            }
            guard let photosDictionary = results?[FlickrClient.ResponseKeys.Photos] as? [String:AnyObject], let photoArrayOfDictionaries = photosDictionary[FlickrClient.ResponseKeys.Photo] as? [[String:AnyObject]] else {
                print("There was an error parsing photos")
                completionHandlerForGETPhotosUsingPage(false, "An error occured downloading photos from Flickr!")
                return
            }
            //print("Successfully parsed photos!")
            
            for photoDictionary in photoArrayOfDictionaries {
                let photo = Photo(dictionary: photoDictionary, context: AppDelegate.stack.context)
                photo.pin = pin
            }
            completionHandlerForGETPhotosUsingPage(true, nil)
        }
    }
}
