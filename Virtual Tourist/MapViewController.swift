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
  var pressRecognizer: UILongPressGestureRecognizer?
  
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
    pressRecognizer = UILongPressGestureRecognizer(target: self, action: "handlePress:")
    pressRecognizer?.minimumPressDuration = 0.5
    
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
    self.view.addGestureRecognizer(pressRecognizer!)
  }
  
  /// remove tap recogniser from the map view
  func removeKeyboardDismissRecognizer() {
    self.view.removeGestureRecognizer(tapRecognizer!)
    self.view.removeGestureRecognizer(pressRecognizer!)
  }
  
  /// overwrite the annotation view so we can add an info button
  func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
    var annotation = view.annotation
    checkPinTapped(annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
  }
  
  /// Add a pin to the map.
  /// :param:  pin The Pin to add to the map (given latitude and longitude)
  func addPinToMap(pin: Pin) {
    var newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as CLLocationDegrees, longitude: pin.longitude as CLLocationDegrees)
    
    var annotationPoint = MKMapPointForCoordinate(newAnnotation.coordinate)
    
    dispatch_async(dispatch_get_main_queue(), {
        
      /// Add all of the annotations to the view
      self.MapView.addAnnotation(newAnnotation)
    })
  }
  
  /// Check if we should add a pin to the map.
  /// :param:  pin The Pin to add to the map (given latitude and longitude)
  func checkAddPinToMap(latitude: NSNumber, longitude: NSNumber) {
    
    var newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
    
    var annotationPoint = MKMapPointForCoordinate(newAnnotation.coordinate)

    /// divide up into a grid of 10 x 10
    /// and only add a new pin if outside that area (otherwise the view will get too cluttered)
    var gridWidth = MapView.visibleMapRect.size.width/10
    var gridHeight = MapView.visibleMapRect.size.height/10
    var origin = MKMapPoint(x: annotationPoint.x - gridWidth/2, y: annotationPoint.y - gridWidth/2)
    var bounding = MKMapRect(origin: origin, size: MKMapSize(width: gridWidth, height: gridHeight))
    
    var inBounding = self.MapView.annotationsInMapRect(bounding)
    if (inBounding.count == 0) {
      // No pins around to create a new one and add to the map
      
      let dictionary: [String : AnyObject] = [
        Pin.Keys.Latitide : latitude,
        Pin.Keys.Longitude : longitude,
      ]
      
      /// Now we create a new Person, using the shared Context
      let pinToBeAdded = Pin(dictionary: dictionary, context: sharedContext)
      addPinToMap(pinToBeAdded)
      CoreDataStackManager.sharedInstance().saveContext()
      
    }
  }
  
  /// Check if a pin  the map.
  /// :param:  pin The Pin to add to the map (given latitude and longitude)
  func checkPinTapped(latitude: NSNumber, longitude: NSNumber) {
    
    var newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
    
    var annotationPoint = MKMapPointForCoordinate(newAnnotation.coordinate)
    
    /// divide up into a grid of 10 x 10
    /// and only add a new pin if outside that area (otherwise the view will get too cluttered)
    var gridWidth = MapView.visibleMapRect.size.width/10
    var gridHeight = MapView.visibleMapRect.size.height/10
    var origin = MKMapPoint(x: annotationPoint.x - gridWidth/2, y: annotationPoint.y - gridWidth/2)
    var bounding = MKMapRect(origin: origin, size: MKMapSize(width: gridWidth, height: gridHeight))
    
    var inBounding = self.MapView.annotationsInMapRect(bounding)
    if (inBounding.count > 0) {
      /// Since there is a close annotation, use the first one in the array
      /// as the reference point for fetching photos
      var nearestAnnotation = inBounding.first as! MKPointAnnotation
      var pinLatitude = nearestAnnotation.coordinate.latitude
      var pinLongitude = nearestAnnotation.coordinate.longitude
      
      /// Add each pin to the map
      var pressedPin: Pin? = nil
      /// Perform the first fetch of Pins to populate the map.
      var FetchResult = fetchedResultsController.performFetch(nil)
      if (FetchResult) {
        /// Only try to use the pins if the fetch was successfull
        var pins = fetchedResultsController.fetchedObjects! as NSArray
        
        for pin in pins {
          if (pin.latitude == pinLatitude && pin.longitude == pinLongitude) {
            pressedPin = pin as? Pin
            break;
          }
        }
        
      }
      
      let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoMapView") as! PhotoMapViewController
      controller.focusPin = pressedPin
      self.presentViewController(controller, animated: true, completion: nil)
    }
    
    //VTClient.sharedInstance().searchPhotosByLocation(latitude as Double, longitude: longitude as Double) { results, errorString
    //      println(results)
    //}
  }
  
  /// The map has been tapped, so add a new annoation if one not already there
  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    var pointTapped:CGPoint = recognizer.locationInView(self.MapView)
    var locationTapped:CLLocationCoordinate2D = self.MapView.convertPoint(pointTapped, toCoordinateFromView: self.MapView)
  
    /// Add the newly create pin to the map
    checkPinTapped(locationTapped.latitude, longitude: locationTapped.longitude)
  }
  
  
  /// The map has been tapped, so add a new annoation if one not already there
  func handlePress(recognizer: UILongPressGestureRecognizer!) {
    var pointPressed:CGPoint = recognizer.locationInView(self.MapView)
    var locationPressed:CLLocationCoordinate2D = self.MapView.convertPoint(pointPressed, toCoordinateFromView: self.MapView)
    
    /// Add the newly create pin to the map
    checkAddPinToMap(locationPressed.latitude, longitude: locationPressed.longitude)
  }
}

