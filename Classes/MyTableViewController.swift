//
//  MyTableViewController.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/29.
//
//
/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Primary view controller used to display search results.
 */

import UIKit
import CoreLocation
import MapKit

@objc(MyTableViewController)
class MyTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var places: [MKMapItem] = []
    
    //MARK: -
    
    private let kCellIdentifier = "cellIdentifier"
    
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    private var localSearch: MKLocalSearch?
    @IBOutlet weak var viewAllButton: UIBarButtonItem!
    private var locationManager: CLLocationManager!
    private var userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return .all
        } else {
            return .allButUpsideDown
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapViewController = segue.destination as! MapViewController
        
        if segue.identifier == "showDetail" {
            // Get the single item.
            let selectedItemPath = self.tableView.indexPathForSelectedRow!
            let mapItem = self.places[selectedItemPath.row]
            
            // Pass the new bounding region to the map destination view controller.
            var region = self.boundingRegion
            // And  C it on the single placemark.
            region.center = mapItem.placemark.coordinate
            mapViewController.boundingRegion = region
            
            // Pass the individual place to our map destination view controller.
            mapViewController.mapItemList = [mapItem]
            
        } else if segue.identifier == "showAll" {
            
            // Pass the new bounding region to the map destination view controller.
            mapViewController.boundingRegion = self.boundingRegion
            
            // Pass the list of places found to our map destination view controller.
            mapViewController.mapItemList = self.places
        }
    }
    
    
    //MARK: - UITableView delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        
        let mapItem = self.places[indexPath.row]
        cell.textLabel!.text = mapItem.name
        
        return cell
    }
    
    
    //MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the text changed, reset the tableview if it wasn't empty.
        if self.places.count != 0 {
            
            // Set the list of places to be empty.
            self.places = []
            // Reload the tableview.
            self.tableView.reloadData()
            // Disable the "view all" button.
            self.viewAllButton.isEnabled = false
        }
    }
    
    private func startSearch(_ searchString: String?) {
        if self.localSearch?.isSearching ?? false {
            self.localSearch!.cancel()
        }
        
        // Confine the map search area to the user's current location.
        var newRegion = MKCoordinateRegion()
        newRegion.center.latitude = self.userCoordinate.latitude
        newRegion.center.longitude = self.userCoordinate.longitude
        
        // Setup the area spanned by the map region:
        // We use the delta values to indicate the desired zoom level of the map,
        //      (smaller delta values corresponding to a higher zoom level).
        //      The numbers used here correspond to a roughly 8 mi
        //      diameter area.
        //
        newRegion.span.latitudeDelta = 0.112872
        newRegion.span.longitudeDelta = 0.109863
        
        let request = MKLocalSearchRequest()
        
        request.naturalLanguageQuery = searchString
        request.region = newRegion
        
        let completionHandler: MKLocalSearchCompletionHandler = {response, error in
            if let actualError = error as NSError? {
                let errorStr = actualError.userInfo[NSLocalizedDescriptionKey] as! String
                let alert = UIAlertController(title: "Could not find places",
                    message: errorStr,
                    preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.places = response!.mapItems
                
                // Used for later when setting the map's region in "prepareForSegue".
                self.boundingRegion = response!.boundingRegion
                
                self.viewAllButton.isEnabled = !self.places.isEmpty
                
                self.tableView.reloadData()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        self.localSearch = MKLocalSearch(request: request)
        
        self.localSearch!.start(completionHandler: completionHandler)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        // Check if location services are available
        guard CLLocationManager.locationServicesEnabled() else {
            NSLog("%@: location services are not available.", #function)
            
            // Display alert to the user.
            let alert = UIAlertController(title: "Location services",
                message: "Location services are not enabled on this device. Please enable location services in settings.",
                preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style:UIAlertActionStyle.default,
                handler:{action in}) // Do nothing action to dismiss the alert.
            
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Request "when in use" location service authorization.
        // If authorization has been denied previously, we can display an alert if the user has denied location services previously.
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .denied {
            NSLog("%@: location services authorization was previously denied by the user.", #function)
            
            // Display alert to the user.
            let alert = UIAlertController(title: "Location services",
                message: "Location services were previously denied by the user. Please enable location services for this app in settings.",
                preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,
                handler: {action in}) // Do nothing action to dismiss the alert.
            
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Start updating locations.
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        // When a location is delivered to the location manager delegate, the search will actually take place. See the -locationManager:didUpdateLocations: method.
    }
    
    
    //MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Remember for later the user's current location.
        let userLocation = locations.last!
        self.userCoordinate = userLocation.coordinate
        
        manager.stopUpdatingLocation() // We only want one update.
        
        manager.delegate = nil         // We might be called again here, even though we
        // called "stopUpdatingLocation", so remove us as the delegate to be sure.
        
        // We have a location now, so start the search.
        self.startSearch(self.searchBar.text)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // report any errors returned back from Location Services
    }
    
}
