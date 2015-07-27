//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 18/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
  
  @IBOutlet weak var MapView: MKMapView!
  var tapRecognizer: UITapGestureRecognizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Add a tap recogniser for the map view
    // This is where new pins will be added
    tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
    tapRecognizer?.numberOfTapsRequired = 1
    addKeyboardDismissRecognizer()
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
  
  
  /// The map has been tapped, so add a new annoation if one not already there
  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    var pointTapped:CGPoint = recognizer.locationInView(self.MapView)
    var locationTapped:CLLocationCoordinate2D = self.MapView.convertPoint(pointTapped, toCoordinateFromView: self.MapView)
    
    var newAnnotation = MKPointAnnotation()
    
    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: locationTapped.latitude, longitude: locationTapped.longitude)
    
    dispatch_async(dispatch_get_main_queue(), {
  
      /// Add all of the annotations to the view
      self.MapView.addAnnotation(newAnnotation)
    })
  
  }
}

