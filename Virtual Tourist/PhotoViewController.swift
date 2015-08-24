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
  var displayPhotos = [Photo]()
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
    
    displayPhotos.removeAll(keepCapacity: false)
    
    /// This class is the FetchedResultsController delegate
    fetchedResultsController.delegate = self
    
    /// Set this class to be the delegate
    self.CollectionView?.delegate = self
    self.CollectionView?.dataSource = self
    
    var goToFlickr = false
    /// Perform the first fetch of Pins to populate the map.
    var FetchResult = fetchedResultsController.performFetch(nil)
    if (FetchResult) {
      /// Only try to use the pins if the fetch was successfull
      var photos = fetchedResultsController.fetchedObjects! as NSArray
      
      /// Check if we actually had any photos stored
      if (photos.count == 0) {
        goToFlickr = true
      } else {
        for photo in photos {
          let newPhoto = photo as! Photo
          displayPhotos.append(newPhoto)
        }
      }
    } else {
      goToFlickr = true
    }
    
    if (goToFlickr) {
      
      dispatch_async(dispatch_get_main_queue(), {
        self.CollectionView.reloadData()
      })
      /// Get photos from Flickr
      VTClient.sharedInstance().searchPhotosByLocation(self.focusPin.latitude as Double, longitude: self.focusPin.longitude as Double, page: nil) { results, errorString in
        if let errorString = errorString {
          println("Error = \(errorString)")
        } else {
          if let photosDictionary = results!.valueForKey("photos") as? [String:AnyObject] {
            
            if let totalPages = photosDictionary["pages"] as? Int {
              
              /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
              let pageLimit = min(totalPages, 40)
              let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
              VTClient.sharedInstance().searchPhotosByLocation(self.focusPin.latitude as Double, longitude: self.focusPin.longitude as Double, page: randomPage) { results, errorString in
                if let photosDictionary = results!.valueForKey("photos") as? [String:AnyObject] {
                  
                  var totalPhotosVal = 0
                  if let totalPhotos = photosDictionary["total"] as? String {
                    totalPhotosVal = (totalPhotos as NSString).integerValue
                  }
                  
                  /// we want to display 21 photos
                  if totalPhotosVal > 0 {
                    if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                      var total = 0
                    
                      while (total < min(21, totalPhotosVal)) {
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                        let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                        
                        let photoTitle = photoDictionary["title"] as? String
                        let imageUrlString = photoDictionary["url_m"] as? String
                        let id = photoDictionary["id"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        let imageData = NSData(contentsOfURL: imageURL!)
                        let image = UIImage(data: imageData!)
                        println("photo \(total)= \(imageURL)")
                        total += 1
                        let dictionary: [String : AnyObject] = [
                          Photo.Keys.id: id as! AnyObject,
                          Photo.Keys.url: imageUrlString as! AnyObject,
                          Photo.Keys.image: imageData as! AnyObject
                        ]
                        
                        /// Now we create a new Photo, using the shared Context
                        let photoAtPin = Photo(dictionary: dictionary, context: self.sharedContext)
                        photoAtPin.pin = self.focusPin
                        
                        self.displayPhotos.append(photoAtPin)
                        dispatch_async(dispatch_get_main_queue(), {
                          // Since we have all the photos also reload the Collection View
                          self.CollectionView.reloadData()
                        })
                      }
                      
                      // Downloaded all of the photos we need so okay to save now
                      CoreDataStackManager.sharedInstance().saveContext()
              
                    } else {
                      println("Cant find key 'photo' in \(photosDictionary)")
                    }
                  } else {
                  }
                }
                
              }
              
            } else {
              println("Cant find key 'pages' in \(photosDictionary)")
            }
          } else {
            println("Cant find key 'photos' in \(results)")
          }
        }
      }
    } else {
      dispatch_async(dispatch_get_main_queue(), {
        self.CollectionView.reloadData()
      })
    }
  }
  
  /// Return the number of saved Meme images to show
  ///
  /// :param: collectionView The collection view controller
  /// :param: section The index into the collection view
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 21
  }
  
  /// Return the Photo for the desired index
  ///
  /// :param: collectionView The collection view controller
  /// :param: indexPath The index of the item in the collection view
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoViewCell
    
    if (self.displayPhotos.count > indexPath.row) {
      let newPhoto = self.displayPhotos[indexPath.row]
    
      /// Set the photo
      photoCell.imageView?.image = UIImage(data: newPhoto.image)
      photoCell.imageView?.hidden = false
      photoCell.loadBusy?.hidden = true
      photoCell.layer.cornerRadius = 1
    } else {
      photoCell.imageView?.hidden = true
      photoCell.loadBusy?.hidden = false
      photoCell.layer.cornerRadius = 6
    }
    
    return photoCell
  }
  
  /// View the selected Photo in the MemeViewController
  ///
  /// :param: collectionView The collection view controller
  /// :param: indexPath The index of the item selected
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {

  }
}
