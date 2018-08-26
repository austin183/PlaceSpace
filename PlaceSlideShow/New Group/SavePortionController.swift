//
//  SavePortionController.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/19/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Cocoa


class SavePortionController: NSViewController {
    private var gifWriter:GifWriter = GifWriter()
    var place:Place?
    
    @IBOutlet weak var scale: NSTextField!
    
    @IBOutlet weak var xValue: NSTextField!
    @IBOutlet weak var yValue: NSTextField!
    
    @IBOutlet weak var height: NSTextField!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var stopIndex: NSTextField!
    @IBOutlet weak var startIndex: NSTextField!
    @IBOutlet weak var skipFrames: NSTextField!

    @IBOutlet weak var gifFps: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = NSApp.delegate as! AppDelegate
        place = appDelegate.getPlace()
        startIndex.integerValue = 0
        stopIndex.integerValue = place!.getContentsCount()
        gifFps.integerValue = 16
        yValue.integerValue = 0
        xValue.integerValue = 0
        width.integerValue = 0
        height.integerValue = 0
        scale.doubleValue = 1.0
        validateRange()
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
    
    @IBAction func gifFpsChanged(_ sender: NSTextField) {
        validateRange()
    }
    
    private func validateCropRectangleCoordinates() -> Bool{
        let x:Int = getNonNegativeValue(value: yValue.integerValue)
        let y:Int = getNonNegativeValue(value: xValue.integerValue)
        var wd:Int = getNonNegativeValue(value: width.integerValue)
        var ht:Int = getNonNegativeValue(value: height.integerValue)
        yValue.textColor = NSColor.black
        xValue.textColor = NSColor.black
        width.textColor = NSColor.black
        height.textColor = NSColor.black
        
        if(x == 0 && y == 0 && wd == 0 && ht == 0){
            return true//the GifWriter will not try to crop this dataset
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
        var stop:Int = stopIndex.integerValue
        var start:Int = startIndex.integerValue
        skipFrames.integerValue = 0
        if stop - start < 0 {
            swap(&start, &stop)
        }
        startIndex.integerValue = start
        stopIndex.integerValue = stop
        if stop - start > 100{
            let distance:Int = stop - start
            var skip:Int = Int(distance / 100)
            if skip <= 1{
                skip = 0
            }
            skipFrames.integerValue = skip
        }
        if gifFps.integerValue <= 0{
            gifFps.integerValue = 1
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let panel = NSSavePanel()
        let launcherLogPathWithTilde = "~/Pictures" as NSString
        let expandedLauncherLogPath = launcherLogPathWithTilde.expandingTildeInPath
        panel.directoryURL = NSURL.fileURL(withPath: expandedLauncherLogPath, isDirectory: true)
        panel.title = "Save GIF"
        panel.message = "Please save the GIF somewhere"
        panel.nameFieldLabel = "Name to give GIF file"
        panel.allowedFileTypes = ["gif"]
        panel.nameFieldStringValue = "PlaceSnippet"
        gifWriter.setRange(start: startIndex.integerValue, stop: stopIndex.integerValue, skipFrames:skipFrames.integerValue, gifFPS:gifFps.integerValue)
        if(validateCropRectangleCoordinates()){
            gifWriter.setCropRectangleCoordinates(yValue: yValue.integerValue, xValue: xValue.integerValue, width: width.integerValue, height: height.integerValue)
        }
        
        panel.beginSheetModal(for: self.view.window!, completionHandler: { num in
            if num == NSApplication.ModalResponse.OK {
                self.gifWriter.writeGif(destinationPath: panel.url!, place: self.place!, scale:self.scale.doubleValue)
            } else {
                print("nothing chosen")
            }
        })
    }
}
