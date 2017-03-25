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
        
        newCollectionButton.isEnabled = false
        configureLocation()
        executeSearch()
        fetchedResultsController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        print("viewDidLoad called")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        
        if pin?.photos?.count == 0 {
            
            FlickrClient.sharedInstance().getPhotosUsingFlickr2(pin) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        AppDelegate.stack.save()
                    }
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutCollectionView()
        print("subView layed out")
    }
    
    // MARK: Actions
    @IBAction func pressedNewCollectionButton(_ sender: Any) {
        
        if selectedIndexes.isEmpty {
            newCollectionButton.isEnabled = false
            deleteAllPhotos()
        } else {
            deleteSelectedPhotos()
        }
        
        /*if selectedIndexes.isEmpty {
            deleteAllPhotos()
            newCollectionButton.isEnabled = false
            
            FlickrClient.sharedInstance().getPhotosUsingFlickr(pin) { ( success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        AppDelegate.stack.save()
                        //self.collectionView.reloadData()
                        self.newCollectionButton.isEnabled = true
                        print("Collection Button enabled")
                    }
                }
            }
        } else {
            deleteSelectedPhotos()
        }*/
    }
    
    // MARK: UIFunctions
    func updateButton() {
        if selectedIndexes.count > 0 {
            newCollectionButton.setTitle("Remove Selected Photos", for: .normal)
        } else {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    
    func checkifButtonShouldChange(checkIf cell: PhotoAlbumCollectionViewCell, isDisplaying placeHolder: UIImage) {
        if cell.photoAlbumCollectionImageView.image == placeHolder {
            newCollectionButton.isEnabled = false
        } else {
            newCollectionButton.isEnabled = true
        }
    }
    
    func configureCell(_ cell: PhotoAlbumCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let photo = self.fetchedResultsController.object(at: indexPath as IndexPath) as! Photo
        let placeHolderImage = UIImage(named: "Flickr_icon")
        var cellImage = placeHolderImage
        
        cell.photoAlbumCollectionImageView.image = nil
        
        if let image = photo.image {
            cellImage = UIImage(data: image)
        } else {
            
            let task = FlickrClient.sharedInstance().getFlickrImages(photo) { (success, errorString, imageData) in
                if let error = errorString {
                    print("Error occured in configureCell()")
                    cellImage = nil
                } else {
                    if let data = imageData {
                        photo.image = data
                        performUIUpdatesOnMain {
                            cell.photoAlbumCollectionImageView.image = UIImage(data: data)
                        }
                    } else {
                        print("Could not get the image data in configureCell")
                    }
                }
            
            }
            cell.taskToCancelIfCellReused = task
        }
        cell.photoAlbumCollectionImageView.image = cellImage
        
        checkifButtonShouldChange(checkIf: cell, isDisplaying: placeHolderImage!)
        
        if let index = selectedIndexes.index(of: indexPath as NSIndexPath) {
            cell.photoAlbumCollectionImageView.alpha = 0.25
        } else {
            cell.photoAlbumCollectionImageView.alpha = 1.0
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
        
        if pin?.photos?.count == 0 {
            FlickrClient.sharedInstance().getPhotosUsingFlickr2(pin) { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        AppDelegate.stack.save()
                    }
                }
            
            }
        }
    }
    
    func deleteSelectedPhotos() {
        
        var deletedPhotos = [Photo]()
        for indexPath in selectedIndexes {
            deletedPhotos.append(fetchedResultsController.object(at: indexPath as IndexPath) as! Photo)
        }
        for photo in deletedPhotos {
            AppDelegate.stack.context.delete(photo)
        }
        selectedIndexes = [NSIndexPath]()
        updateButton()
    }
    
    // MARK: - UICollectionsviewDelegate Methods
    /*func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("numberOfItemsInSection called")
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        print(sectionInfo.numberOfObjects)
        //return sectionInfo.numberOfObjects
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("cellForItemAt called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        configureCell(cell, atIndexPath: indexPath as NSIndexPath)
        
        
        /*let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath as IndexPath) as! PhotoAlbumCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath as IndexPath) as! Photo
        cell.activityIndicator.stopAnimating()
        if photo.image != nil {
            cell.photoAlbumCollectionImageView.image = UIImage(data: (photo.image)!)
        }*/
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    

            let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
            
            if let index = selectedIndexes.index(of: indexPath as NSIndexPath) {
                selectedIndexes.remove(at: index)
            } else {
                selectedIndexes.append(indexPath as NSIndexPath)
            }
            configureCell(cell, atIndexPath: indexPath as NSIndexPath)
            updateButton()

        
        /*let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        if let index = selectedIndexes.index(of: indexPath as NSIndexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath as NSIndexPath)
        }
        print(selectedIndexes.count)
        if selectedIndexes.count > 0 {
            newCollectionButton.setTitle("Remove Selected Photos", for: .normal)
        } else {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }*/
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
        },  completion: nil)
    }
}
