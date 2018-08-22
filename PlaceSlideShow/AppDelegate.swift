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
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func setPlace(placeToSet:Place){
        place = placeToSet
    }
    
    func getPlace() -> Place{
        return place!
    }
}

