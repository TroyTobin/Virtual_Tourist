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

  var focusPin: Pin!
  override func viewDidLoad() {
    super.viewDidLoad()
    println(focusPin)
  }
    
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }  
}
