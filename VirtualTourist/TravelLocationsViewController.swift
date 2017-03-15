//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/11/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import UIKit
import CoreData
import MapKit

// MARK: - TravelLocationsViewController: UIViewController

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: Properties
    enum PresentationState { case configure, on, off }
    var presentationState: Bool!
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: Outlets
    @IBOutlet weak var doneButtonNavigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsView: UIView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        mapView.delegate = self
        fetchedResultsController?.delegate = self
        executeSearch()
        loadPersistedRegion()
        setPersistedLocations()
        print("view loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view appeared")
    }
    
    // MARK: Actions
    @IBAction func editbuttonPressed(_ sender: AnyObject) {
        toggleDeletePinsView(.on)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        toggleDeletePinsView(.off)
    }
    
    @IBAction func addPinToMap(_ sender: UILongPressGestureRecognizer) {
    
        if sender.state == UIGestureRecognizerState.began {
            let location = sender.location(in: self.mapView)
            let locationCoord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            let pinAnnotation = Pin(latitude: locationCoord.latitude, longitude: locationCoord.longitude, context: AppDelegate.stack.context)
            self.mapView.addAnnotation(pinAnnotation)
            /* COULD START GETTING PHOTOS FOR FLICKR HERE */
            do {
                try AppDelegate.stack.save()
                print("SAVED PIN")
            } catch {
                fatalError("Error while saving")
            }
        }
    }

    // MARK: UIFunctions
    func configureUI() {
        toggleDeletePinsView(.configure)
    }
    
    func executeSearch() {
        
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    func setPersistedLocations() {
        
        executeSearch()
        for pin in fetchedResultsController?.fetchedObjects as! [Pin] {
            mapView.addAnnotation(pin)
            print("Loaded Annotation")
        }
    }
    
    func loadPersistedRegion() {
        
        if let region = UserDefaults.standard.object(forKey: "region") as AnyObject? {
            let latitude = region["latitude"] as! CLLocationDegrees
            let longitude = region["longitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let latDelta = region["latitudeDelta"] as! CLLocationDegrees
            let longDelta = region["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let updatedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(updatedRegion, animated: true)
        }
    }
    
    private func toggleDeletePinsView(_ presentationState: PresentationState) {
        
        switch presentationState {
            case .configure:
                deletePinsView.isHidden = true
                doneButtonNavigationBar.isHidden = true
                self.presentationState = false
            case .on:
                if deletePinsView.isHidden {
                    mapView.frame.origin.y -= deletePinsView.frame.height
                    deletePinsView.isHidden = false
                    self.navigationController?.isNavigationBarHidden = true
                    doneButtonNavigationBar.isHidden = false
                    self.presentationState = true
                }
            case .off:
                if !deletePinsView.isHidden {
                    mapView.frame.origin.y += deletePinsView.frame.height
                    deletePinsView.isHidden = true
                    self.navigationController?.isNavigationBarHidden = false
                    doneButtonNavigationBar.isHidden = true
                    self.presentationState = false
                }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayPhotoAlbumViewController" {
            let pin = sender as! MKPinAnnotationView
            let nextController = segue.destination as! PhotoAlbumViewController
            nextController.pin = pin
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
            pinView!.isDraggable = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if presentationState == false {
            mapView.deselectAnnotation(view.annotation, animated: true)
            let pin = view.annotation as! Pin
            performSegue(withIdentifier: "displayPhotoAlbumViewController", sender: pin)
        } else {
            if presentationState == true {
                let pin = view.annotation as! Pin
                mapView.removeAnnotation(pin)
                AppDelegate.stack.context.delete(pin)
                do {
                    try AppDelegate.stack.save()
                } catch {
                    fatalError("Error while saving")
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let persistedRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(persistedRegion, forKey: "region")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending {
            let annotation = view.annotation as! Pin
            mapView.addAnnotation(annotation)
            do {
                try AppDelegate.stack.save()
            } catch {
                fatalError("Error while saving")
            }
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
