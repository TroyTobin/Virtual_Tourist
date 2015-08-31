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

  @IBOutlet weak var photoActionButton: UIBarButtonItem!
  @IBOutlet weak var mapView: MKMapView!
  var focusPin: Pin!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// add observer for photo cell selection
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellSelected:", name: "cellSelected",object: nil)
    /// add observer for photo cell deselecton
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellDeSelected:", name: "cellDeSelected",object: nil)
    
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
  
  /// cell selected so switch the "new collection" title to "Remove Selected Pictures"
  func cellSelected(notification: NSNotification) {
    photoActionButton.title = "Remove Selected Pictures"
  }
  
  
  /// cell de-selected so switch the "Remove Selected Pictures" title to "new collection"
  func cellDeSelected(notification: NSNotification) {
    photoActionButton.title = "New Collection"
  }
  
  
  @IBAction func newCollection(sender: AnyObject) {
    
    /// notify the photo view to reload the photos
    NSNotificationCenter.defaultCenter().postNotificationName("refreshPhotoAlbum", object: nil)
  }
  
  
  
  @IBAction func dismissView(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
