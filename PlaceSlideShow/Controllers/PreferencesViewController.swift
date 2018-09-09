//
//  PreferencesViewController.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/25/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var startingIndex: NSTextField!
    @IBOutlet weak var startingFPS: NSTextField!
    @IBOutlet weak var defaultDirectory: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let defaults = UserDefaults.standard
        let si = defaults.string(forKey: "startingIndex")
        let sf = defaults.string(forKey: "startingFPS")
        let dd = defaults.string(forKey: "defaultDirectory")
        if(si != nil && si != ""){
            startingIndex.stringValue = si!
        }
        else{
            startingIndex.stringValue = "20"
        }
        if sf != nil && sf != "" {
            startingFPS.stringValue = sf!
        }
        else{
            startingFPS.stringValue = "30"
        }
        if dd != nil && dd != "" {
            defaultDirectory.stringValue = dd!
        }
    }
    
    @IBAction func findDefaultDirectory(_ sender: NSButton) {
        getUserSelectedPlaceDirectory()
    }
    
    @IBAction func fpsChanged(_ sender: NSTextField) {
    }
    
    @IBAction func startingIndexChanged(_ sender: NSTextField) {
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let defaults = UserDefaults.standard
        if defaultDirectory.stringValue != "" {
            defaults.set(URL(fileURLWithPath: defaultDirectory.stringValue), forKey: "defaultDirectory")
        }
        if startingFPS.stringValue != "" {
            defaults.set(startingFPS.stringValue, forKey: "startingFPS")
        }
        if startingIndex.stringValue != "" {
            defaults.set(startingIndex.stringValue, forKey: "startingIndex")
        }
        self.view.window?.close()
    }
    
    fileprivate func getUserSelectedPlaceDirectory() {
        let dialog = NSOpenPanel()
        let launcherLogPathWithTilde = "~/Pictures" as NSString
        let expandedLauncherLogPath = launcherLogPathWithTilde.expandingTildeInPath
        dialog.directoryURL = NSURL.fileURL(withPath: expandedLauncherLogPath, isDirectory: true)
        dialog.title = "Which folder in the Pictures folder has all the images to display?"
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false
        dialog.showsResizeIndicator = true
        dialog.message = "Which folder in the Pictures folder has all the images to display?"
        
        if(dialog.runModal() == NSApplication.ModalResponse.OK){
            let placeDirectory = dialog.directoryURL!
            let place = Place()
            place.buildPngContents(placeDirectory: placeDirectory)
            if(place.getContentsCount() > 0){
                defaultDirectory.stringValue = placeDirectory.path
            }
        }
    }
    
}
