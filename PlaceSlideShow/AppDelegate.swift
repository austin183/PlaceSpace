//
//  AppDelegate.swift
//  PlaceSlideShow
//
//  Created by Austin on 4/24/17.
//  Copyright © 2017 Austin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var place:Place?
    private var dimensions:Dimensions?
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setDimensions(dimensionsToSet:Dimensions){
        dimensions = dimensionsToSet
    }
    
    func getDimensions() -> Dimensions{
        return dimensions!
    }

    func setPlace(placeToSet:Place){
        place = placeToSet
    }
    
    func getPlace() -> Place{
        return place!
    }
}

