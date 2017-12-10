# MapSearch

## Description

Demonstrates how to programmatically search for map-based addresses and points of interest using the `MKLocalSearch` class.  It initiates a search for map-based content using a natural language string.  A user can type "coffee," press search and it will find all the coffee places nearby.  The places found are centered around the user's current location. Once the search results have been found, the sample shows various ways to display the results.  It demonstrates how to use `MKLocalSearchCompletionHandler` and populate the `UITableView` with the search results.  It also demonstrates checking and requesting location services authorization. Authorization is requested immediately before location services are needed, after the "Search" button is tapped.

Each found place can be viewed in its own `MKMapView` to show a single annotation or a cluster of annotations describing the search results.

## Build Requirements

Xcode 9 or later, iOS SDK 11.0 or later

## Runtime Requirements

iOS 11.0 or later.

Copyright (C) 2013-2017 Apple Inc. All rights reserved.
