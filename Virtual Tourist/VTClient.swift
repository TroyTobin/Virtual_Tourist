//
//  VTClient.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 01 August 2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation


/// This class represents the On the Map API to the View controllers
class VTClient: NSObject {
  
  /// Network layer
  var vtNet: VTNetLayer
  
  /// initialise and create a VT network layer
  override init() {
    vtNet = VTNetLayer()
    super.init()
  }
  
  /// Convert longitude, latitude to a bounding box string for Flickr
  func locationToBoundingBox(latitude: Double, longitude: Double) -> String {
    let southWestLongitude = max(longitude - VTClient.Constants.BoundingBoxWidth/2,  VTClient.Constants.MinLongitude)
    let southWestLatitude  = max(latitude  - VTClient.Constants.BoundingBoxHeight/2, VTClient.Constants.MinLatitude)
    let northEastLongitude = min(longitude + VTClient.Constants.BoundingBoxWidth/2,  VTClient.Constants.MaxLongitude)
    let northEastLatitude  = min(latitude  + VTClient.Constants.BoundingBoxHeight/2, VTClient.Constants.MaxLatitude)
    
    var boundingBox = "\(southWestLongitude),\(southWestLatitude),\(northEastLongitude),\(northEastLatitude)"
    
    return boundingBox
  }
  
  /// Search flickr
  func searchPhotosByLocation(latitude: Double, longitude: Double, page: NSNumber?, completionHandler: (results: AnyObject?, errorString: String?) -> Void) {
    var flickrParameters = [
      "api_key": VTClient.Constants.FlickrApiKey,
      "bbox": locationToBoundingBox(latitude, longitude: longitude),
      "safe_search": String(VTClient.FlickrParameters.SafeSearch.description),
      "extras": VTClient.FlickrParameters.Extras,
      "format": VTClient.FlickrParameters.DataFormat,
      "nojsoncallback": String(VTClient.FlickrParameters.NoJSONCallback)
    ]
    if let page = page {
      flickrParameters["page"] = page.stringValue
    }
    
    /// Create an escaped URL
    var parameters = VTNetLayer.escapeURLParameters(flickrParameters)
    
    vtNet.doGetReq(VTClient.Constants.BaseURLFlickr, method:VTClient.FlickrMethods.Search, params: parameters, header: nil, offset: 0) { result, error in
      if let newError = error {
        completionHandler(results: nil, errorString: newError.localizedDescription)
      } else {
        completionHandler(results: result, errorString: nil)
      }
    }
  }
  
  
  func getNewPhoto(latitude: Double, longitude: Double, photos: NSMutableArray, completionHandler: (photoData: [String: AnyObject]?, errorString: String?) -> Void) {
    /// Get photos from Flickr
    self.searchPhotosByLocation(latitude, longitude: longitude, page: nil) { results, errorString in
      if let errorString = errorString {
        completionHandler(photoData: nil, errorString: errorString)
      } else {
        if let photosDictionary = results!.valueForKey("photos") as? [String:AnyObject] {
          
          if let totalPages = photosDictionary["pages"] as? Int {
            
            /// Get a random page of photos to then get our random photos from
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            // retrive photos from the random page
            self.searchPhotosByLocation(latitude, longitude: longitude, page: randomPage) { results, errorString in
              if let errorString = errorString {
                completionHandler(photoData: nil, errorString: errorString)
              }
              // get the list of photos
              if let photosList = results!.valueForKey("photos") as? [String:AnyObject] {
                
                /// determine how many photos where retrieved from Flickr
                var totalPhotosVal = 0
                if let totalPhotos = photosList["total"] as? String {
                  totalPhotosVal = (totalPhotos as NSString).integerValue
                }
                
                /// we want at least 1 photo
                while (totalPhotosVal > 0) {
                  totalPhotosVal -= 1
                  if let photosArray = photosList["photo"] as? [[String: AnyObject]] {
                    /// Get a random photo
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoInformation = photosArray[randomPhotoIndex]
                      
                    /// Get the photo information to store
                    let imageUrlString = photoInformation["url_m"] as? String
                    let id = photoInformation["id"] as? String
                    
                    // check if this is a duplicate
                    var j = 0
                    var duplicate = false
                    for (j = 0; j < photos.count; j++) {
                      let photo = photos[j] as! Photo
                      if (id == photo.id) {
                        // found a duplicate
                        duplicate = true
                        break
                      }
                    }
                    if(duplicate == false) {
                      let imageURL = NSURL(string: imageUrlString!)
                      let imageData = NSData(contentsOfURL: imageURL!)
                      
                      /// Set the photo dictionary to use in the contructor
                      var dictionary: [String : AnyObject] = [
                        "id": id as! AnyObject,
                        "url": imageUrlString as! AnyObject,
                        "imageData": imageData as! AnyObject
                      ]
                    
                      // return the new photo to the caller
                      completionHandler(photoData: dictionary, errorString: nil)
                      return
                    }
                  } else {
                    completionHandler(photoData: nil, errorString: "Cant find key 'photo' in \(results)")
                  }
                }
                completionHandler(photoData: nil, errorString: "Cant find any photos")
              } else {
                completionHandler(photoData: nil, errorString: "Cant find key 'photos' in \(results)")
              }
            }
          } else {
            completionHandler(photoData: nil, errorString: "Cant find key 'pages' in \(photosDictionary)")
          }
        } else {
          completionHandler(photoData: nil, errorString: "Cant find key 'photos' in \(results)")
        }
      }
    }
  }

  
  /// Return the client singleton
  class func sharedInstance() -> VTClient {
    struct Singleton {
      static var sharedInstance = VTClient()
    }
    return Singleton.sharedInstance
  }
}