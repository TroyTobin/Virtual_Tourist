//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 01 August 2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  var focusPin: Pin!
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  /// About to segue, so set the recorded data on the play audio view controller
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
  {
    if("showMap" == segue.identifier)
    {
      let smallMap:SmallMapViewController = segue.destinationViewController as! SmallMapViewController;
      
      let pin = focusPin as Pin;
      smallMap.focusPin = pin;
    } else if("showPhotos" == segue.identifier)
      {
        let photos:PhotoViewController = segue.destinationViewController as! PhotoViewController;
        
        let pin = focusPin as Pin;
        photos.focusPin = pin;
    }
  }
  
}
