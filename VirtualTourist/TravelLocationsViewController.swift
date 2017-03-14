//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/11/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import UIKit
import MapKit

// MARK: - TravelLocationsViewController: UIViewController

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    enum PresentationState { case configure, on, off }
    var presentationState: Bool!
    
    // MARK: Outlets
    @IBOutlet weak var doneButtonNavigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsView: UIView!

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = locationCoord
            self.mapView.addAnnotation(pinAnnotation)

            /* SAVE TO COREDATA */
        }
    }

    // MARK: UIFunctions
    func configureUI() {
        toggleDeletePinsView(.configure)
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
            let annotation = sender as! MKPinAnnotationView
            let nextController = segue.destination as! PhotoAlbumViewController
            /* set properties (ie. nextController.annotation = annotation */
        }
    }
    
    // MARK: UtilityFuncs
    
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
            let annotation = view.annotation as! MKPinAnnotationView
            performSegue(withIdentifier: "displayPhotoAlbumViewController", sender: annotation)
        } else {
            if presentationState == true {
                let annotation = view.annotation
                mapView.removeAnnotation(annotation!)
                /* DELETE annotation FROM CORE DATA */
                /* SAVE TO COREDATA */
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
        /* ADD persistedRegion TO NSUSERDEFAULTS */
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending {
            let annotation = view.annotation as! MKPointAnnotation
            let coordinate = annotation.coordinate
        }
    }
}
