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
  var displayPhotos: NSMutableArray = []
  var selectedCells: NSMutableArray = []
  var MAX_PHOTOS_IN_ALBUM = 21
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
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    /// Student information downloaded so need to refresh the view
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPhotoAlbum:", name: "refreshPhotoAlbum",object: nil)
    
    displayPhotos.removeAllObjects()
    
    /// This class is the FetchedResultsController delegate
    fetchedResultsController.delegate = self
    
    /// Set this class to be the delegate
    self.CollectionView?.delegate = self
    self.CollectionView?.dataSource = self
    
    var downloadPhotos = true
    /// Perform the first fetch of Pins to populate the map.
    var FetchResult = fetchedResultsController.performFetch(nil)
    if (FetchResult) {
      /// Only try to use the pins if the fetch was successfull
      var photos = fetchedResultsController.fetchedObjects! as NSArray
      
      /// Check if we actually had any photos stored
      if (photos.count > 0) {
        
        // Photos are cached so use those
        downloadPhotos = false
        for photo in photos {
          let newPhoto = photo as! Photo
          displayPhotos.addObject(newPhoto)
          displayPhotoAlbum()
        }
      }
    }
    
    // Do we need to download a photo set?
    if (downloadPhotos) {
      downloadNewPhotoSet()
    }
  }
  
  // Dsiplay a photo album by refreshing the collection View
  func displayPhotoAlbum() {
    dispatch_async(dispatch_get_main_queue(), {
        self.CollectionView.reloadData()
    })
  }
  
  
  // Download a new set of photos to be displayed
  func downloadNewPhotoSet() {
    /// We need to download <= 21 photos
    var photoFetches = 0
    while (photoFetches++ < MAX_PHOTOS_IN_ALBUM) {
      VTClient.sharedInstance().getNewPhoto(self.focusPin.latitude as Double, longitude: self.focusPin.longitude as Double, photos: self.displayPhotos) { photoData, errorString in
        if let errorString = errorString {
          // No photo returned
          println("Failed to retrieve photo - \(errorString)")
        } else {
          // Get a new photo so add it to the list and display it
          let newPhoto = Photo(dictionary: photoData!, image: photoData!["imageData"] as! NSData, context: self.sharedContext)
          newPhoto.pin = self.focusPin
          self.displayPhotos.addObject(newPhoto)
          self.displayPhotoAlbum()
        }
      }
    }

  }
  
  /// refresh the photo view
  func refreshPhotoAlbum(notification: NSNotification) {
    // there are no photos selected so we are getting a whole new collections
    if (selectedCells.count == 0) {
      
      // Remove the existing photo set
      for photo in displayPhotos {
        (photo as? Photo)!.delete()
        sharedContext.deleteObject(photo as! NSManagedObject)
      }
      CoreDataStackManager.sharedInstance().saveContext()
      displayPhotos.removeAllObjects()
    
      // Download a new photo set
      downloadNewPhotoSet()
      
    } else {
      // there are selected cells so we are removing select cells.
      /// Find the label (it containes the url)
      var removedPhotos = [Photo]()
      
      // figure out which photos need to be removed based on their index in
      // the collection
      for cellIndex in selectedCells {
        var photo : Photo = displayPhotos.objectAtIndex(cellIndex as! Int) as! Photo
        removedPhotos.append(photo)
      }
      
      // Actually remove the photos
      for photo in removedPhotos {
        displayPhotos.removeObject(photo)
        photo.delete()
        sharedContext.deleteObject(photo as NSManagedObject)
      }
      
      CoreDataStackManager.sharedInstance().saveContext()
      selectedCells.removeAllObjects()
      // re-display teh photo album now it has changed
      self.displayPhotoAlbum()
      
      NSNotificationCenter.defaultCenter().postNotificationName("cellDeSelected", object: nil)
      
    }
  }
  
  /// Return the number of saved Meme images to show
  ///
  /// :param: collectionView The collection view controller
  /// :param: section The index into the collection view
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return MAX_PHOTOS_IN_ALBUM
  }
  
  /// Return the Photo for the desired index
  ///
  /// :param: collectionView The collection view controller
  /// :param: indexPath The index of the item in the collection view
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoViewCell

    if (self.displayPhotos.count > indexPath.row) {
      let newPhoto = self.displayPhotos.objectAtIndex(indexPath.row) as! Photo
    
      /// Set the photo
      // Need to retrieve it from the file system
      if let newImage = newPhoto.image() {

        photoCell.imageView?.image = newImage
        /// add the id to the image (invisible) so we can retrieve it later
        var photoLabel = UILabel()
        photoLabel.text = newPhoto.id
        photoLabel.backgroundColor = UIColor.clearColor()
        photoLabel.textColor =  UIColor.clearColor()
      
        photoCell.imageView?.addSubview(photoLabel)
        photoCell.imageView?.hidden = false
        photoCell.loadBusy?.hidden = true
        photoCell.layer.cornerRadius = 1
        if ( selectedCells.containsObject(indexPath.row) ) {
          photoCell.imageView.layer.borderWidth = 2.0
          photoCell.imageView.layer.borderColor = UIColor.blueColor().CGColor
          photoCell.imageView.layer.opacity = 0.2
        } else {
          photoCell.imageView.tag = 0
          photoCell.imageView.layer.borderWidth = 0.0
          photoCell.imageView.layer.borderColor = UIColor.blueColor().CGColor
          photoCell.imageView.layer.opacity = 1.0
        }
      }
    } else {
      photoCell.imageView?.hidden = true
      photoCell.loadBusy?.hidden = false
      photoCell.layer.cornerRadius = 6
    }
    photoCell.imageView.tag = 0
    return photoCell
  }
  
  /// View the selected Photo in the MemeViewController
  ///
  /// :param: collectionView The collection view controller
  /// :param: indexPath The index of the item selected
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
    
    var cell: PhotoViewCell? = self.CollectionView.cellForItemAtIndexPath(indexPath) as? PhotoViewCell
    if (selectedCells.containsObject(indexPath.row)) {
      selectedCells.removeObject(indexPath.row)
      if (selectedCells.count == 0) {
        NSNotificationCenter.defaultCenter().postNotificationName("cellDeSelected", object: nil)
      }
      cell!.imageView.tag = 0
      cell!.imageView.layer.borderWidth = 0.0
      cell!.imageView.layer.borderColor = UIColor.blueColor().CGColor
      cell!.imageView.layer.opacity = 1.0
    } else {
      
      selectedCells.addObject(indexPath.row)
      NSNotificationCenter.defaultCenter().postNotificationName("cellSelected", object: nil)
      cell!.imageView.tag = 1
      cell!.imageView.layer.borderWidth = 2.0
      cell!.imageView.layer.borderColor = UIColor.blueColor().CGColor
      cell!.imageView.layer.opacity = 0.2
    }
  }
}
