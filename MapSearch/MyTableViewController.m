/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Primary view controller used to display search results.
 */

#import "MyTableViewController.h"
#import "MapViewController.h"

#import <MapKit/MapKit.h>

#pragma mark -

static NSString *kCellIdentifier = @"cellIdentifier";

@interface MyTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray<MKMapItem *> *places;

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *viewAllButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (nonatomic, strong) UISearchController *searchController;

@end


#pragma mark -

@implementation MyTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    _locationManager = [[CLLocationManager alloc] init];
	
	_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];

	// We place the search bar in the navigation bar.
	self.navigationItem.searchController = self.searchController;
	
	// We want the search bar visible all the time.
	self.navigationItem.hidesSearchBarWhenScrolling = NO;
	
	self.searchController.dimsBackgroundDuringPresentation = NO;
	self.searchController.searchBar.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MapViewController *mapViewController = segue.destinationViewController;
	
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        // Get the single item.
        NSIndexPath *selectedItemPath = self.tableView.indexPathForSelectedRow;
        MKMapItem *mapItem = self.places[selectedItemPath.row];
		
        // Pass the new bounding region to the map destination view controller.
        MKCoordinateRegion region = self.boundingRegion;
        // And center it on the single placemark.
        region.center = mapItem.placemark.coordinate;
        mapViewController.boundingRegion = region;
		
        // Pass the individual place to our map destination view controller.
        mapViewController.mapItemList = @[mapItem];
		
    } else if ([segue.identifier isEqualToString:@"showAll"]) {
		
         // Pass the new bounding region to the map destination view controller.
         mapViewController.boundingRegion = self.boundingRegion;
		
         // Pass the list of places found to our map destination view controller.
         mapViewController.mapItemList = self.places;
     }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.places.count;
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
    MKMapItem *mapItem = self.places[indexPath.row];
    cell.textLabel.text = mapItem.name;

	return cell;
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[self.searchController dismissViewControllerAnimated:YES completion:^() {
		
		// Check if location services are available
		if ([CLLocationManager locationServicesEnabled] == NO) {
			NSLog(@"%s: location services are not available.", __PRETTY_FUNCTION__);
			
			// Display alert to the user.
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
																		   message:@"Location services are not enabled on this device. Please enable location services in Settings."
																	preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
																	style:UIAlertActionStyleDefault
																  handler:nil];
			
			[alert addAction:defaultAction];
			[self presentViewController:alert animated:YES completion:nil];
			return;
		}
		
		// Request "when in use" location service authorization.
		// If authorization has been denied previously, we can display an alert if the user has denied location services previously.
		if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
			[self.locationManager requestWhenInUseAuthorization];
		} else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
			NSLog(@"%s: location services authorization was previously denied by the user.", __PRETTY_FUNCTION__);
			
			// Display alert to the user.
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
																		   message:@"Location services were previously denied by the user. Please enable location services for this app in Settings."
																	preferredStyle:UIAlertControllerStyleAlert];
			
			UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings"
																	 style:UIAlertActionStyleDefault
																   handler:^(UIAlertAction *action) {
																	   // Take the user to Settings app to possibly change permission.
																	   NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
																	   [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
																   }];
			[alert addAction:settingsAction];
			
			UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
																	style:UIAlertActionStyleDefault
																  handler:nil];
			[alert addAction:defaultAction];
			
			[self presentViewController:alert animated:YES completion:nil];
			return;
		}
		
		// Ask for our location.
		self.locationManager.delegate = self;
		[self.locationManager requestLocation];
		
		// When a location is delivered to the location manager delegate, the search will
		// actually take place. See the -locationManager:didUpdateLocations: method.
	}];
}

- (void)startSearch:(NSString *)searchString {
    if (self.localSearch.searching) {
        [self.localSearch cancel];
    }
	
	// Confine the map search area to the user's current location.
	// Setup the area spanned by the map region.
	// We use the delta values to indicate the desired zoom level of the map.
	//
	CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.userCoordinate.latitude, self.userCoordinate.longitude);
	MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(center, 12000, 12000);
	
	MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
	request.naturalLanguageQuery = searchString;
	request.region = newRegion;
	
	__weak __typeof(self) weakSelf = self;
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            NSString *errorStr = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
			UIAlertController *alertController =
				[UIAlertController alertControllerWithTitle:@"Could not find any places."
													message:errorStr
											 preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
														 style:UIAlertActionStyleDefault
													   handler:nil];
			[alertController addAction:ok];
			
			[weakSelf presentViewController:alertController animated:YES completion:nil];
        } else {
            _places = response.mapItems;
			
            // Used for later when setting the map's region in "prepareForSegue".
            _boundingRegion = response.boundingRegion;
			
            weakSelf.viewAllButton.enabled = weakSelf.places != nil ? YES : NO;
			
            [weakSelf.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
	
    if (self.localSearch != nil) {
        _localSearch = nil;
    }
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	_places = [NSArray array];
	
    _localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [self.localSearch startWithCompletionHandler:completionHandler];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Remember for later the user's current location.
    CLLocation *userLocation = locations.lastObject;
    self.userCoordinate = userLocation.coordinate;
	
    manager.delegate = nil;	// We might be called again here, even though we
                     		// called "stopUpdatingLocation", so remove us as the delegate to be sure.
	
    // We have a location now, so start the search.
	[self startSearch:self.searchController.searchBar.text];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // report any errors returned back from Location Services
}

@end

