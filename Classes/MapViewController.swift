//
//  MapViewController.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/28.
//
//
/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Secondary view controller used to display the map and found annotations.
 */

import UIKit
import MapKit

@objc(MapViewController)
class MapViewController: UIViewController, MKMapViewDelegate {
    
    var mapItemList: [MKMapItem] = []
    var boundingRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    @IBOutlet private weak var mapView: MKMapView?
    private var annotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust the map to zoom/center to the annotations we want to show.
        self.mapView?.setRegion(self.boundingRegion, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // We add the placemarks here to get the "drop" animation.
        if self.mapItemList.count == 1 {
            let mapItem = self.mapItemList[0]
            
            self.title = mapItem.name
            
            // Add the single annotation to our map.
            let annotation = PlaceAnnotation()
            annotation.coordinate = mapItem.placemark.location!.coordinate
            annotation.title = mapItem.name
            annotation.url = mapItem.url
            self.mapView!.addAnnotation(annotation)
            
            // We have only one annotation, select it's callout.
            self.mapView!.selectAnnotation(self.mapView!.annotations[0], animated: true)
        } else {
            self.title = "All Places"
            
            // Add all the found annotations to the map.
            
            for item in self.mapItemList {
                let annotation = PlaceAnnotation()
                annotation.coordinate = item.placemark.location!.coordinate
                annotation.title = item.name
                annotation.url = item.url
                self.mapView!.addAnnotation(annotation)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.mapView!.removeAnnotations(self.mapView!.annotations)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            return UIInterfaceOrientationMask.All
        } else {
            return UIInterfaceOrientationMask.AllButUpsideDown
        }
    }
    
    
    //MARK: - MKMapViewDelegate
    
    func mapViewDidFailLoadingMap(mapView: MKMapView, withError error: NSError) {
        NSLog("Failed to load the map: %@", error)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView? = nil
        
        if annotation is PlaceAnnotation {
            annotationView = self.mapView!.dequeueReusableAnnotationViewWithIdentifier("Pin") as! MKPinAnnotationView?
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView!.canShowCallout = true
                annotationView!.animatesDrop = true
            }
        }
        return annotationView
    }
    
}