//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 18/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreData

/// Photo is a managed object
class Photo : NSManagedObject {
  
  struct Keys {
    static let id   = "id"
    static let url  = "url"
  }
  
  ///Set the Photo attributes to Core data attributes
  @NSManaged var id:  String
  @NSManaged var url:  String
  @NSManaged var path: String
  @NSManaged var pin:  Pin
  
  /// initialise the Core data
  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
  
  
  /// Initialise the photo with a dictionary
  init(dictionary: [String : AnyObject], image: NSData, context: NSManagedObjectContext) {
    
    // Get the entity associated with the Photo type
    let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
    
    // Init for Managed object - this will store the object
    super.init(entity: entity,insertIntoManagedObjectContext: context)
    
    // Set the photos attributes
    id   = dictionary[Keys.id]  as! String
    url  = dictionary[Keys.url]  as! String
    
    // get the path to the documents directory for this application
    let documentsDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
    
    // Create the image file name for storage on teh file system
    path = "\(documentsDirPath)/\(id).png"
    
    // Save the image to file
    dispatch_async(dispatch_get_main_queue(), {
     UIImagePNGRepresentation(UIImage(data: image)).writeToFile(self.path, atomically: true)
    })
  }
  
  /// Delete the image from the documents directory
  func delete() {
    /// First check that the file exits
    var fileManager = NSFileManager.defaultManager()
    if (fileManager.fileExistsAtPath(path)) {
      fileManager.removeItemAtPath(path, error: nil)
    }
  }
  
  /// Return the Image for this photo - or nil if it doesn't exist
  func image() -> UIImage? {
    // first check if the file exists at the designated path
    var fileManager = NSFileManager.defaultManager()
    if (fileManager.fileExistsAtPath(path)) {
      return UIImage(contentsOfFile: path)!
    }
    return nil
  }
}


