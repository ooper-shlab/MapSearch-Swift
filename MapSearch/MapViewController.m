/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Secondary view controller used to display the map and found annotations.
 */

#import "MapViewController.h"
#import "PlaceAnnotation.h"

@interface MapViewController () <MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@end

static NSString *Identifier = @"Pin";

#pragma mark -

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Adjust the map to zoom/center to the annotations we want to show.
    [self.mapView setRegion:self.boundingRegion animated:YES];
	self.mapView.delegate = self;
	
	// Show the compass button in our navigation bar.
	MKCompassButton *compassButton = [MKCompassButton compassButtonWithMapView:self.mapView];
	compassButton.compassVisibility = MKFeatureVisibilityVisible;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:compassButton];
	self.mapView.showsCompass = NO;	// Use the compass in the navigation bar instead.
	
	// Make sure MKPinAnnotationView and our reuse identifier are recognized in this table view.
	[self.mapView registerClass:[MKPinAnnotationView class] forAnnotationViewWithReuseIdentifier:Identifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // We add the placemarks here to get the "drop" animation.
    if (self.mapItemList.count == 1) {
        MKMapItem *mapItem = self.mapItemList[0];
        
        self.title = mapItem.name;
        
        // Add the single annotation to our map.
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
		annotation.url = mapItem.url;
        [self.mapView addAnnotation:annotation];
        
        // We have only one annotation, select it's callout.
        [self.mapView selectAnnotation:self.mapView.annotations[0] animated:YES];
    } else {
        self.title = @"All Places";
        
        // Add all the found annotations to the map.
        for (MKMapItem *mapItem in self.mapItemList) {
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
            annotation.coordinate = mapItem.placemark.location.coordinate;
            annotation.title = mapItem.name;
			
			// The URL will be used to open their website when the annotation's Info button is tapped.
			annotation.url = mapItem.url;
			
			[self.mapView addAnnotation:annotation];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
}


#pragma mark - MKMapViewDelegate

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"Failed to load the map: %@", error);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
 	MKPinAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:Identifier forAnnotation:annotation];
		annotationView.canShowCallout = YES;
		annotationView.animatesDrop = YES;

		// If the annotation has a URL, add an extra Info button to the annotation view so users open that URL.
		PlaceAnnotation *annotation = [annotationView annotation];
		if (annotation.url != nil) {
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			annotationView.rightCalloutAccessoryView = rightButton;
		}
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	// Here we illustrate how to detect which annotation type was clicked on for its callout.
	id <MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
		PlaceAnnotation *annotation = [view annotation];
		NSURL *url = annotation.url;	// User tapped the annotation's Info Button.
		if (url != nil) {
			[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
				// Completed openURL.
			}];
		}
	}
}

@end
