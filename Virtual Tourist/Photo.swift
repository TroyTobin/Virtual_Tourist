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
    static let Id  = "Id"
  }
  
  ///Set the Photo attributes to Core data attributes
  @NSManaged var Id: String
  @NSManaged var pin: Pin
  
  /// initialise the Core data
  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
  
  
  /// Initialise the photo with a dictionary
  init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
    
    
    // Get the entity associated with the Photo type
    let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
    
    // Init for Managed object - this will store the object
    super.init(entity: entity,insertIntoManagedObjectContext: context)
    
    // Set the pins attributes
    Id  = dictionary[Keys.Id] as! String
  }
}


