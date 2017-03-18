//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/11/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import UIKit
import CoreData
import MapKit

// MARK: - PhotoAlbumViewController: UIViewController

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    var pin: Pin?
    
    // Create NSIndexPath arrays to store selected collection view cells
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // Create NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        executeSearch()
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLocation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutCollectionView()
    }
    
    // MARK: Actions
    @IBAction func pressedNewCollectionButton(_ sender: Any) {
    
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            /* TODO: DISABLE COLLECTION BUTTON */
            
            FlickrClient.sharedInstance().getPhotosUsingFlickr(pin) { ( success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        AppDelegate.stack.save()
                        self.collectionView.reloadData()
                        /* TODO: ENABLE COLLECTION BUTTON */
                    }
                }
            }
            
        } else {
            deleteSelectedPhotos()
        }
        self.collectionView.reloadData()
    }
    
    // MARK: UIFunctions
    func configureCell(_ cell: PhotoAlbumCollectionViewCell, atIndexPath IndexPath: NSIndexPath) {
        
        let photo = fetchedResultsController.object(at: IndexPath as IndexPath) as! Photo
        if let imageData = photo.image {
            cell.photoAlbumCollectionImageView.image = UIImage(data: imageData as Data)
        }
    }
    
    func layoutCollectionView() {
        
        let space: CGFloat = 3.0
        let dimension = (self.collectionView.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func configureLocation() {
        
        if let mapAnnotation = pin {
            let coordinate = CLLocationCoordinate2D(latitude: mapAnnotation.latitude, longitude: mapAnnotation.longitude)
            mapView.addAnnotation(mapAnnotation)
            mapView.camera.altitude = 10000.0
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func executeSearch() {
        
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
    }
    
    // MARK: UtilityFuncs
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            AppDelegate.stack.context.delete(photo)
        }
        AppDelegate.stack.save()
        selectedIndexes = [NSIndexPath]()
    }
    
    func deleteSelectedPhotos() {
        
        var deletedPhotos = [Photo]()
        for indexPath in selectedIndexes {
            deletedPhotos.append(fetchedResultsController.object(at: indexPath as IndexPath) as! Photo)
        }
        for photo in deletedPhotos {
            AppDelegate.stack.context.delete(photo)
        }
        AppDelegate.stack.save()
        selectedIndexes = [NSIndexPath]()
    }
    
    // MARK: - UICollectionsviewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath as IndexPath) as! PhotoAlbumCollectionViewCell
        configureCell(cell, atIndexPath: indexPath as NSIndexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        if let index = selectedIndexes.index(of: indexPath as NSIndexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath as NSIndexPath)
        }
        /* TODO: TOGGLE BUTTON HERE */
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }

    // MARK: - NSFetchedResultsControllerDelegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
        let set = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            self.collectionView.insertSections(set)
        case .delete:
            self.collectionView.deleteSections(set)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath! as NSIndexPath)
            break
        case .delete:
            deletedIndexPaths.append(indexPath! as NSIndexPath)
        case .update:
            updatedIndexPaths.append(indexPath! as NSIndexPath)
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath as IndexPath])
            }
        }, completion: nil)
    }
}
