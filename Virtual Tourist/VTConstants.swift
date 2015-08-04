//
//  VTConstants.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 01 August 2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

//// Sets constants for the OTM Client in this extension
extension VTClient {
  
  // MARK: - Constants
  struct Constants {
    static let FlickrApiKey      = "PUT-API-KEY-HERE"
    
    static let BaseURLFlickr     = "https://api.flickr.com/services/rest/"
    
    /// 1 Degree bounding box for location
    static let BoundingBoxWidth  = 1.0
    static let BoundingBoxHeight = 1.0
    
    /// Min/Max Latitude and Longitude in degrees
    static let MinLongitude      = -180.0
    static let MaxLongitude      = 180.0
    static let MinLatitude       = -90.0
    static let MaxLatitude       = 90.0
  }
  
  // MARK: - Flickr Methods
  struct FlickrMethods {
    static let Search = "flickr.photos.search"
  }
  
  // MARK: - Flickr Parameters
  struct FlickrParameters {
    static let Extras         = "url_m"
    static let SafeSearch     = 1
    static let DataFormat     = "json"
    static let NoJSONCallback = 1
  }
  
  // MARK: - Flickr HTTP Header
  struct FlckrHTTPHeader {
    static let Accept = ["field": "Accept", "value": "application/json"]
    static let ContentType = ["field": "Content-Type", "value": "application/json"]
  }
}