//
//  VTNetLayer.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 01 August 2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

import UIKit


/// This class provides an api layer for performing http requests to flickr
class VTNetLayer: NSObject {
  
  var session: NSURLSession
  
  /// Initialise the Network Layer
  override init() {
    session = NSURLSession.sharedSession()
  }
  
  /// Escape URL parameters to create valid URL encoding
  class func escapeURLParameters(parameters: [String : String]?) -> String {
    
    var urlParameters = ""
    
    if let inParameters = parameters {
      urlParameters += "?"
      for (key, value) in inParameters {
        
        /// escape the parameter
        let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /// append the parameter to create a string of the form 'key=value&'
        urlParameters += "\(key)=\(escapedValue!)&"
      }
    }
    
    return urlParameters
  }
  
  /// Convert a blob of binary json to ascii encoded json
  /// Note: this block of code is found in the "Movie Manager" presented as
  ///       a part of the iOS Networking Udacity Course
  class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsingError: NSError? = nil
    
    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
    
    /// check for errors and return the appropriate response to the completion handler
    if let error = parsingError {
      completionHandler(result: nil, error: error)
    } else {
      completionHandler(result: parsedResult, error: nil)
    }
  }
  
  /// Perform a HTTP Get request to the specified URL, method and parameters
  func doGetReq(baseURL: String, method: String, params: String?, header: [NSDictionary]?, offset: Int,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    var fullUrl: NSURL? = nil
    
    /// set the url string
    if let inParams = params {
      fullUrl = NSURL(string: "\(baseURL)/\(inParams)method=\(method)")
    } else {
      fullUrl = NSURL(string:"\(baseURL)/?method=\(method)")
    }
    
    /// create the URL request and set the http parameters
    let request = NSMutableURLRequest(URL: fullUrl!)
    request.HTTPMethod = "GET"
    if let inHeader = header {
      for item in inHeader {
        if let value = item.valueForKey("value") as? String {
          if let field = item.valueForKey("field") as? String {
            request.addValue(value, forHTTPHeaderField: field)
          }
        }
      }
    }
    
    /// perform the GET request
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        /// There was an error so return as such
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Get data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        /// offset the returned data if necessary - this is required for the udacity
        /// data that is returned
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
        /// Parse the data to JSON
        VTNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
}