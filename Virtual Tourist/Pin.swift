//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 18/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreData

/// Pin is a managed object
class Pin : NSManagedObject {
  
  struct Keys {
    static let Latitide  = "Latitude"
    static let Longitude = "Longitude"
  }
  
  ///Set the Pin attributes to Core data attributes
  @NSManaged var latitude: NSNumber
  @NSManaged var longitude: NSNumber
  @NSManaged var photos: [Photo]
  

  /// initialise the Core data
  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
  
  /// Initialise the pin with a dictionary
  init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
    
    // Get the entity associated with the Pin type
    let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
    
    // Init for Managed object - this will store the object
    super.init(entity: entity,insertIntoManagedObjectContext: context)
    
    // Set the pins attributes
    latitude  = dictionary[Keys.Latitide] as! NSNumber
    longitude = dictionary[Keys.Longitude] as! NSNumber
  }
}


