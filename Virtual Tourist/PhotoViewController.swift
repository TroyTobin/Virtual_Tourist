//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Troy Tobin on 14/08/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreData

class PhotoViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var focusPin: Pin!
  @IBOutlet var CollectionView: UICollectionView!
  
  /// Managed object context
  var sharedContext: NSManagedObjectContext {
    return CoreDataStackManager.sharedInstance().managedObjectContext!
  }
  
  /// Fetch controller to retrieve managed obejcts
  lazy var fetchedResultsController: NSFetchedResultsController = {
    
    let fetchRequest = NSFetchRequest(entityName: "Photo")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "pin == %@", self.focusPin);
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
      managedObjectContext: self.sharedContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
    
    return fetchedResultsController
    
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// This class is the FetchedResultsController delegate
    fetchedResultsController.delegate = self
    
    /// Perform the first fetch of Pins to populate the map.
    var FetchResult = fetchedResultsController.performFetch(nil)
    if (FetchResult) {
      /// Only try to use the pins if the fetch was successfull
      println("fetched photos = \(FetchResult)")
      var photos = fetchedResultsController.fetchedObjects! as NSArray
      println("photos = \(photos)")
    }
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    /// Set this class to be the delegate
    self.CollectionView?.delegate = self
    self.CollectionView?.dataSource = self
    

    /// Reload the memes in the collection view
    self.CollectionView.reloadData()
  }
  
  /// Return the number of saved Meme images to show
  ///
  /// :param: collectionView The collection view controller
  /// :param: section The index into the collection view
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 0
  }
  
  /// Return the Photo for the desired index
  ///
  /// :param: collectionView The collection view controller
  /// :param: indexPath The index of the item in the collection view
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoViewCell
    
    // @TODO get the photo and set the image view for the cell
    
    return photoCell
  }
  
  /// View the selected Photo in the MemeViewController
  ///
  /// :param: collectionView The collection view controller
  /// :param: indexPath The index of the item selected
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {

  }
}
