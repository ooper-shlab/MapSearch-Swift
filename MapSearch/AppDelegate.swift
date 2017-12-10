//
//  AppDelegate.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/29.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The application delegate class used for installing our navigation controller.
 */

import UIKit

@UIApplicationMain
@objc(AppDelegate)
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // The app delegate must implement the window @property
    // from UIApplicationDelegate @protocol to use a main storyboard file.
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        let storyboard: UIStoryboard
        if #available(iOS 11.0, *) {
            storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        } else {
            storyboard = UIStoryboard(name: "MainStoryboard", bundle: Bundle.main)
        }
        let vc = storyboard.instantiateInitialViewController()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()

        return true
    }
    
}
