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
  func searchPhotosByLocation(latitude: Double, longitude: Double, completionHandler: (results: AnyObject?, errorString: String?) -> Void) {
    let flickrParameters = [
      "api_key": VTClient.Constants.FlickrApiKey,
      "bbox": locationToBoundingBox(latitude, longitude: longitude),
      "safe_search": String(VTClient.FlickrParameters.SafeSearch.description),
      "extras": VTClient.FlickrParameters.Extras,
      "format": VTClient.FlickrParameters.DataFormat,
      "nojsoncallback": String(VTClient.FlickrParameters.NoJSONCallback)
    ]
    
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
  
  /// Return the client singleton
  class func sharedInstance() -> VTClient {
    struct Singleton {
      static var sharedInstance = VTClient()
    }
    return Singleton.sharedInstance
  }
}