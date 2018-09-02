//
//  SavePortionController.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/19/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Cocoa


class SavePortionController: NSViewController {
    private var movieWriter:MovieWriter = MovieWriter()
    private var imageHandler:ImageHandler = ImageHandler()
    private var mostRecentExport:URL? = nil
    private var skipFramesChanged:Bool = false
    var place:Place?
    var dimensions:Dimensions?
    let skipFrameFactor:Int = 200
    
    @IBOutlet weak var progressUpdate: NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var scale: NSTextField!
    @IBOutlet weak var xValue: NSTextField!
    @IBOutlet weak var yValue: NSTextField!
    @IBOutlet weak var height: NSTextField!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var stopIndex: NSTextField!
    @IBOutlet weak var startIndex: NSTextField!
    @IBOutlet weak var skipFrames: NSTextField!
    @IBOutlet weak var exportFPS: NSTextField!
    @IBOutlet weak var warning: NSTextField!
    @IBOutlet weak var openLastExport: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = NSApp.delegate as! AppDelegate
        movieWriter.delegate = self
        place = appDelegate.getPlace()
        dimensions = appDelegate.getDimensions()
        if(dimensions != nil){
            yValue.integerValue = (dimensions!.originY)
            xValue.integerValue = (dimensions!.originX)
            width.integerValue = (dimensions!.width)
            height.integerValue = (dimensions!.height)
            scale.doubleValue = (dimensions!.scale as NSString).doubleValue
        }
        else{
            startIndex.integerValue = 0
            stopIndex.integerValue = place!.getContentsCount()
            exportFPS.integerValue = 30
            yValue.integerValue = 0
            xValue.integerValue = 0
            width.integerValue = 0
            height.integerValue = 0
            scale.doubleValue = 1.0
        }
        startIndex.integerValue = 0
        stopIndex.integerValue = place!.getContentsCount()
        exportFPS.integerValue = 16
        skipFrames.integerValue = 0
        validateRange()
    }
    
    @IBAction func openLastExportClicked(_ sender: NSButton) {
        let fileManager = FileManager.default
        if(mostRecentExport == nil) { return }
        if fileManager.fileExists(atPath: mostRecentExport!.path) {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: mostRecentExport!.deletingLastPathComponent().path)
        } else {
            return
        }
    }
    @IBAction func topLeftXChanged(_ sender: NSTextField) {
        _ = validateCropRectangleCoordinates()
    }
    
    @IBAction func topLeftYChanged(_ sender: NSTextField) {
        _ = validateCropRectangleCoordinates()
    }
    
    @IBAction func bottomRightYChanged(_ sender: NSTextField) {
        _ = validateCropRectangleCoordinates()
    }
    
    @IBAction func bottomRightXChanged(_ sender: NSTextField) {
        _ = validateCropRectangleCoordinates()
    }
    
    @IBAction func startIndexChanged(_ sender: NSTextField) {
        validateRange()
    }
    @IBAction func stopIndexChanged(_ sender: NSTextField) {
        validateRange()
    }
    
    @IBAction func exportFpsChanged(_ sender: NSTextField) {
        validateRange()
    }
    
    @IBAction func skipFramesChanged(_ sender: NSTextField) {
        skipFramesChanged = true
        validateRange()
    }
    private func validateCropRectangleCoordinates() -> Bool{
        let x:Int = getNonNegativeValue(value: yValue.integerValue)
        let y:Int = getNonNegativeValue(value: xValue.integerValue)
        var wd:Int = getNonNegativeValue(value: width.integerValue)
        var ht:Int = getNonNegativeValue(value: height.integerValue)
        
        if(x == 0 && y == 0 && wd == 0 && ht == 0){
            return true//the MovieWriter will not try to crop this dataset
        }
        if(wd + x > 1000){
            wd = 1000 - x
        }
        if(ht + y > 1000){
            ht = 1000 - y
        }
        return true
    }
    
    private func getNonNegativeValue(value:Int) -> Int{
        if(value < 0){
            return 0
        }
        return value
    }
    
    private func validateRange(){
        warning.isHidden = true
        var stop:Int = stopIndex.integerValue
        var start:Int = startIndex.integerValue
        if stop - start < 0 {
            swap(&start, &stop)
        }
        startIndex.integerValue = start
        stopIndex.integerValue = stop
        if stop - start > skipFrameFactor {
            let distance:Int = stop - start
            var skip:Int = Int(distance / skipFrameFactor)
            if !skipFramesChanged{
                if skip <= 1{
                    skip = 0
                }
                skipFrames.integerValue = skip
            }
            else if skipFrames.integerValue < skip{
                warning.isHidden = false
                warning.stringValue = "The number of frames expected from this process is \(Int(distance / skipFrames.integerValue) + 1), which could take up significant memory and resources.  Please consider setting skip frames higher than \(skip)"
            }
        }
        if exportFPS.integerValue <= 0{
            exportFPS.integerValue = 1
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let panel = NSSavePanel()
        let launcherLogPathWithTilde = "~/Pictures" as NSString
        let expandedLauncherLogPath = launcherLogPathWithTilde.expandingTildeInPath
        panel.directoryURL = NSURL.fileURL(withPath: expandedLauncherLogPath, isDirectory: true)
        panel.title = "Save MP4"
        panel.message = "Please save the MP4 somewhere"
        panel.nameFieldLabel = "Name to give MP4 file"
        panel.allowedFileTypes = ["mp4"]
        panel.nameFieldStringValue = "PlaceSnippet"
        panel.canCreateDirectories = true

        movieWriter.setRange(start: startIndex.integerValue, stop: stopIndex.integerValue, skipFrames:skipFrames.integerValue, exportFPS:exportFPS.integerValue)
        if(validateCropRectangleCoordinates()){
            movieWriter.setCropRectangleCoordinates(yValue: yValue.integerValue, xValue: xValue.integerValue, width: width.integerValue, height: height.integerValue)
        }
        panel.beginSheetModal(for: self.view.window!, completionHandler: { num in
            if num == NSApplication.ModalResponse.OK {
                let backingScale = self.view.window?.backingScaleFactor
                panel.endSheet(self.view.window!)
                self.movieWriter.writeMovie(destinationPath: panel.url!, place: self.place!, scale:self.scale.doubleValue, backingScale:backingScale!)
                
                self.mostRecentExport = panel.url!
            } else {
                print("nothing chosen")
            }
        })
        
        
    }
    
    fileprivate func updateExportProgress(section:String, current:Int, total:Int){
        var done = true
        if(current < total){
            done = false
        }

        DispatchQueue.main.async{
            self.progressUpdate.stringValue = "\(section) - \(current) of \(total)"
            self.progressUpdate.isHidden = done
            self.saveButton.isEnabled = done
            if(self.openLastExport.isHidden){
                self.openLastExport.isHidden = !done
            }
        }
    }
}
extension SavePortionController:MovieWriterProtocol{
    func currentProgress(_ section:String, current:Int, total:Int){
        updateExportProgress(section:section, current:current, total:total)
    }
}
