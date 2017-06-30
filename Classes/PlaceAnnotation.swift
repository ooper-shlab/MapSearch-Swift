//
//  PlaceAnnotation.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/28.
//
//
/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Custom pin annotation for display found places.
 */

import MapKit

@objc(PlaceAnnotation)
class PlaceAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    var url: URL?
    
    
    
}
