//
//  MyTableViewController.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/29.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Primary view controller used to display search results.
 */

import UIKit
import CoreLocation

import MapKit

//mark: -

private let kCellIdentifier = "cellIdentifier"

@objc(MyTableViewController)
class MyTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var places: [MKMapItem] = []
    
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    private var localSearch: MKLocalSearch?
    @IBOutlet weak var viewAllButton: UIBarButtonItem!
    private var locationManager: CLLocationManager = CLLocationManager()
    private var userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var searchController: UISearchController!
    //###
    @IBOutlet weak var searchBar: UISearchBar!

    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            
            searchController = UISearchController(searchResultsController: nil)
            
            // We place the search bar in the navigation bar.
            self.navigationItem.searchController = self.searchController;
            
            // We want the search bar visible all the time.
            self.navigationItem.hidesSearchBarWhenScrolling = false
            
            self.searchController.dimsBackgroundDuringPresentation = false
            self.searchController.searchBar.delegate = self
        }
    }
    
//    override var shouldAutorotate : Bool {
//        return true
//    }
//
//    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//        if UI_USER_INTERFACE_IDIOM() == .pad {
//            return .all
//        } else {
//            return .allButUpsideDown
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapViewController = segue.destination as! MapViewController
        
        if segue.identifier == "showDetail" {
            // Get the single item.
            let selectedItemPath = self.tableView.indexPathForSelectedRow!
            let mapItem = self.places[selectedItemPath.row]
            
            // Pass the new bounding region to the map destination view controller.
            var region = self.boundingRegion
            // And center it on the single placemark.
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
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }

    
    //mark: - UITableViewDelegate
    //### As far as I know, `tableView(_:cellForRowAt:)` is declared in UITableViewDataSource...

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        
        let mapItem = self.places[indexPath.row]
        cell.textLabel!.text = mapItem.name
        
        return cell
    }
    
    
    //MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if #available(iOS 11.0, *) {
            //### What to do (or what not to do) for UISearchConroller?
        } else {
            // If the text changed, reset the tableview if it wasn't empty.
            if !self.places.isEmpty {
                
                // Set the list of places to be empty.
                self.places = []
                // Reload the tableview.
                self.tableView.reloadData()
                // Disable the "view all" button.
                self.viewAllButton.isEnabled = false
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let completion = {
            
            // Check if location services are available
            guard CLLocationManager.locationServicesEnabled() else {
                NSLog("%@: location services are not available.", #function)
                
                // Display alert to the user.
                let alert = UIAlertController(title: "Location services",
                                              message: "Location services are not enabled on this device. Please enable location services in Settings.",
                                              preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default,
                                                  handler: nil)
                
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
                                              message: "Location services were previously denied by the user. Please enable location services for this app in Settings.",
                                              preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings",
                    style: .default,
                    handler: {action in
                    // Take the user to Settings app to possibly change permission.
                    let url = URL(string: UIApplicationOpenSettingsURLString)!
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:],  completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    })
                alert.addAction(settingsAction)
                
                let defaultAction = UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil)
                alert.addAction(defaultAction)
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Ask for our location.
            self.locationManager.delegate = self
            if #available(iOS 9.0, *) {
                self.locationManager.requestLocation()
            } else {
                self.locationManager.startUpdatingLocation()
            }
            
            // When a location is delivered to the location manager delegate, the search will
            // actually take place. See the -locationManager:didUpdateLocations: method.
        }
        if #available(iOS 11.0, *) {
            self.searchController.dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
    
    private func startSearch(_ searchString: String?) {
        if self.localSearch?.isSearching ?? false {
            self.localSearch!.cancel()
        }
        
        // Confine the map search area to the user's current location.
        // Setup the area spanned by the map region.
        // We use the delta values to indicate the desired zoom level of the map.
        //
        let center = CLLocationCoordinate2DMake(self.userCoordinate.latitude, self.userCoordinate.longitude)
        let newRegion = MKCoordinateRegionMakeWithDistance(center, 12000, 12000)
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchString
        request.region = newRegion
        
        let completionHandler: MKLocalSearchCompletionHandler = {[weak self] response, error in
            guard let this = self else {return}
            if let actualError = error as NSError? {
                let errorStr = actualError.userInfo[NSLocalizedDescriptionKey] as! String
                let alert = UIAlertController(title: "Could not find places",
                                              message: errorStr,
                                              preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                this.present(alert, animated: true, completion: nil)
            } else {
                this.places = response!.mapItems
                
                // Used for later when setting the map's region in "prepareForSegue".
                this.boundingRegion = response!.boundingRegion
                
                this.viewAllButton.isEnabled = !this.places.isEmpty
                
                this.tableView.reloadData()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        if self.localSearch != nil {
            localSearch = nil
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        places = []

        localSearch = MKLocalSearch(request: request)
        self.localSearch!.start(completionHandler: completionHandler)
    }

    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Remember for later the user's current location.
        let userLocation = locations.last!
        self.userCoordinate = userLocation.coordinate
        
        manager.delegate = nil         // We might be called again here, even though we
        // called "stopUpdatingLocation", so remove us as the delegate to be sure.
        
        // We have a location now, so start the search.
        if #available(iOS 11.0, *) {
            self.startSearch(self.searchController.searchBar.text)
        } else {
            self.startSearch(self.searchBar.text)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // report any errors returned back from Location Services
    }
    
}
