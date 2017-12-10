//
//  MapViewController.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/28.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Secondary view controller used to display the map and found annotations.
 */

import UIKit
import MapKit

private let Identifier = "Pin"

@objc(MapViewController)
class MapViewController: UIViewController, MKMapViewDelegate {
    
    var mapItemList: [MKMapItem] = []
    var boundingRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    @IBOutlet private weak var mapView: MKMapView!
    private var annotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust the map to zoom/center to the annotations we want to show.
        self.mapView?.setRegion(self.boundingRegion, animated: true)
        self.mapView.delegate = self
        
        if #available(iOS 11.0, *) {
            // Show the compass button in our navigation bar.
            let compassButton = MKCompassButton(mapView: self.mapView)
            compassButton.compassVisibility = .visible
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compassButton)
            self.mapView.showsCompass = false    // Use the compass in the navigation bar instead.
        }

        if #available(iOS 11.0, *) {
            // Make sure MKPinAnnotationView and our reuse identifier are recognized in this table view.
            self.mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: Identifier)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            
            for mapItem in self.mapItemList {
                let annotation = PlaceAnnotation()
                annotation.coordinate = mapItem.placemark.location!.coordinate
                annotation.title = mapItem.name
                
                // The URL will be used to open their website when the annotation's Info button is tapped.
                annotation.url = mapItem.url
                
                self.mapView!.addAnnotation(annotation)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.mapView!.removeAnnotations(self.mapView!.annotations)
    }
    
//    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
//            return UIInterfaceOrientationMask.all
//        } else {
//            return UIInterfaceOrientationMask.allButUpsideDown
//        }
//    }
    
    
    //MARK: - MKMapViewDelegate
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        NSLog("Failed to load the map: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView? = nil
        
        if annotation is PlaceAnnotation {
            if #available(iOS 11.0, *) {
                annotationView = (self.mapView!.dequeueReusableAnnotationView(withIdentifier: Identifier, for: annotation) as! MKPinAnnotationView)
                annotationView!.canShowCallout = true
                annotationView!.animatesDrop = true
            } else {
                annotationView = self.mapView!.dequeueReusableAnnotationView(withIdentifier: Identifier) as! MKPinAnnotationView?
                
                if annotationView == nil {
                    annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Identifier)
                    annotationView!.canShowCallout = true
                    annotationView!.animatesDrop = true
                }
            }

            // If the annotation has a URL, add an extra Info button to the annotation view so users open that URL.
            let annotation = annotationView!.annotation as! PlaceAnnotation //### Is this line needed?
            if annotation.url != nil {
                let rightButton = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = rightButton
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Here we illustrate how to detect which annotation type was clicked on for its callout.
        if let annotation = view.annotation as? PlaceAnnotation {
            // User tapped the annotation's Info Button.
            if let url = annotation.url {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options:[:], completionHandler: {success in
                        // Completed openURL.
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
