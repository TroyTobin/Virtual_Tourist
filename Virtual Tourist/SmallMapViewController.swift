//
//  SmallMapViewController.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 14/08/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//
import UIKit
import MapKit
import CoreData

class SmallMapViewController: UIViewController, MKMapViewDelegate {

  
  @IBOutlet weak var mapView: MKMapView!
  
  var focusPin: Pin!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    showPinLocation();

  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  
  func showPinLocation() {
    if let pin = focusPin {
      var newRegion = MKCoordinateRegion()
      var newSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
      newRegion.span = newSpan
      newRegion.span = newSpan;
      newRegion.center = CLLocationCoordinate2D(latitude: pin.latitude as CLLocationDegrees, longitude: pin.longitude as CLLocationDegrees)
      if let theMapView = self.mapView {
        
        dispatch_async(dispatch_get_main_queue(), {
          self.addPinToMap(pin)
          self.mapView.setRegion(newRegion, animated: true)
        })
      }
    }
  }
  
  /// Add a pin to the map.
  /// :param:  pin The Pin to add to the map (given latitude and longitude)
  func addPinToMap(pin: Pin) {
    var newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as CLLocationDegrees, longitude: pin.longitude as CLLocationDegrees)
    
    var annotationPoint = MKMapPointForCoordinate(newAnnotation.coordinate)
    
    dispatch_async(dispatch_get_main_queue(), {
      
      /// Add all of the annotations to the view
      self.mapView.addAnnotation(newAnnotation)
    })
  }

}
