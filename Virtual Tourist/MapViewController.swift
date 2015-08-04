//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 18 July 2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
  
  @IBOutlet weak var MapView: MKMapView!
  var tapRecognizer: UITapGestureRecognizer?
  
  /// Managed object context
  var sharedContext: NSManagedObjectContext {
    return CoreDataStackManager.sharedInstance().managedObjectContext!
  }
  
  /// Fetch controller to retrieve managed obejcts
  lazy var fetchedResultsController: NSFetchedResultsController = {
    
    let fetchRequest = NSFetchRequest(entityName: "Pin")
    
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
      managedObjectContext: self.sharedContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
    
    return fetchedResultsController
    
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Add a tap recogniser for the map view
    // This is where new pins will be added
    tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
    tapRecognizer?.numberOfTapsRequired = 1
    addKeyboardDismissRecognizer()
    
    /// This class is the Mapview delegate
    self.MapView.delegate = self
    
    /// This class is the FetchedResultsController delegate
    fetchedResultsController.delegate = self
    
    /// Perform the first fetch of Pins to populate the map.
    var FetchResult = fetchedResultsController.performFetch(nil)
    if (FetchResult) {
      /// Only try to use the pins if the fetch was successfull
      var pins = fetchedResultsController.fetchedObjects! as NSArray
      /// Add each pin to the map
      for pin in pins {
        let newPin = pin as! Pin
        addPinToMap(newPin)
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.removeKeyboardDismissRecognizer()
  }
  
  /// add tap recogniser to the map view
  func addKeyboardDismissRecognizer() {
    self.view.addGestureRecognizer(tapRecognizer!)
  }
  
  /// remove tap recogniser from the map view
  func removeKeyboardDismissRecognizer() {
    self.view.removeGestureRecognizer(tapRecognizer!)
  }
  
  /// Add a pin to the map.
  /// :param:  pin The Pin to add to the map (given latitude and longitude)
  func addPinToMap(pin: Pin) {
    
    var newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as CLLocationDegrees, longitude: pin.longitude as CLLocationDegrees)
    
    dispatch_async(dispatch_get_main_queue(), {
      
      /// Add all of the annotations to the view
      self.MapView.addAnnotation(newAnnotation)
    })
    VTClient.sharedInstance().searchPhotosByLocation(pin.latitude as Double, longitude: pin.longitude as Double) { results, errorString in

      println(results)
      println(errorString)
    }
  }
  
  /// The map has been tapped, so add a new annoation if one not already there
  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    var pointTapped:CGPoint = recognizer.locationInView(self.MapView)
    var locationTapped:CLLocationCoordinate2D = self.MapView.convertPoint(pointTapped, toCoordinateFromView: self.MapView)
    
    let dictionary: [String : AnyObject] = [
      Pin.Keys.Latitide : locationTapped.latitude,
      Pin.Keys.Longitude : locationTapped.longitude,
    ]
    
    /// Now we create a new Person, using the shared Context
    let pinToBeAdded = Pin(dictionary: dictionary, context: sharedContext)

    /// Add the newly create pin to the map
    addPinToMap(pinToBeAdded)
    
    CoreDataStackManager.sharedInstance().saveContext()
  }
  
  /// overwrite the annotation view so we can add an info button
  ///func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
  ///}
}

