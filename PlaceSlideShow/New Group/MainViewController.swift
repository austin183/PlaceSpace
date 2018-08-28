//
//  ViewController.swift
//  PlaceSlideShow
//
//  Created by Austin on 4/24/17.
//  Copyright © 2017 Austin. All rights reserved.
//

import Cocoa


class MainViewController: NSViewController {
    private var placeDirectory:URL = URL(fileURLWithPath:"")
    private var place:Place = Place()
    
    @IBOutlet weak var fpsText: NSTextField!
    
    @IBOutlet weak var scale: NSTextField!
    @IBOutlet weak var height: NSTextField!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var originY: NSTextField!
    @IBOutlet weak var originX: NSTextField!
    @IBOutlet weak var totalCount: NSTextField!
    @IBOutlet weak var currentIndex: NSTextField!
    @IBOutlet weak var slideShowFPS: NSSlider!
    @IBOutlet weak var imageSlider: NSSliderCell!
    @IBOutlet weak var placeScrollView: NSScrollView!
    @IBOutlet weak var placeImage: NSImageView!
    @IBOutlet weak var btnSlideShow: NSButton!
    
    @IBAction func fpsSliderMoved(_ sender: NSSlider) {
        place.updateSlideShowInterval(slideShowFPS: sender.integerValue)
    }
    
    @IBAction func slideShowClicked(_ sender: NSButton) {
        toggleSlideShow()
    }
    
    @IBAction func moveUpMenuItemSelected(_ sender:NSMenuItem){
        
    }
    
    @IBAction func zoomToFitMenuItemSelected(_ sender:NSMenuItem){
        placeScrollView.magnify(toFit: (placeImage.image?.alignmentRect)!)
    }
    
    @IBAction func zoomOutMenuItemClicked(_ sender:NSMenuItem){
        let magnificationDecrement:CGFloat = CGFloat(0.1)
        
        if(placeScrollView.magnification - magnificationDecrement >= placeScrollView.minMagnification){
            placeScrollView.magnification = placeScrollView.magnification - magnificationDecrement
        }
    }
    
    @IBAction func zoomInMenuItemClicked(_ sender:NSMenuItem){
        let magnificationIncrement:CGFloat = CGFloat(0.1)
        
        if(placeScrollView.magnification + magnificationIncrement <= placeScrollView.maxMagnification){
            placeScrollView.magnification = placeScrollView.magnification + magnificationIncrement
        }
    }
    
    @IBAction func previousMenuItemSelected(_ sender: NSMenuItem) {
        goToPreviousImage()
    }
    
    @IBAction func nextMenuItemSelected(_ sender: NSMenuItem) {
        goToNextImage()
    }
    
    @IBAction func slideShowMenuItemSelected(_ sender: NSMenuItem) {
        toggleSlideShow()
    }
    
    @IBAction func openImageInPreviewMenuItemSelected(_ sender:NSMenuItem){
        let contentsURL:URL = place.getContentAtIndex(index: place.getContentsIndex())
        NSWorkspace.shared.openFile(contentsURL.absoluteString, withApplication: "Preview")
    }
    
    @IBAction func indexSliderMoved(_ sender: NSSliderCell) {
        goToImageAtIndex(index: Int(sender.intValue))
    }
    
    @IBAction func openMenuItemSelected(_ sender: NSMenuItem){
        let currentPlaceDirectory = placeDirectory
        getUserSelectedPlaceDirectory()
        place.buildPngContents(placeDirectory: placeDirectory)
        
        if(place.getContentsCount() > 0){
            let defaults = UserDefaults.standard
            defaults.set(placeDirectory, forKey: "defaultDirectory")
            imageSlider.maxValue = Double(place.getContentsCount() - 1)
            place.setContentsIndex(index: 0)
            updateUI(index: 0)
        }
        else{
            placeDirectory = currentPlaceDirectory
            place.buildPngContents(placeDirectory: placeDirectory)
        }
    }
    
    fileprivate func getUserSelectedPlaceDirectory() {
        let dialog = NSOpenPanel()
        let launcherLogPathWithTilde = "~/Pictures" as NSString
        let expandedLauncherLogPath = launcherLogPathWithTilde.expandingTildeInPath
        dialog.directoryURL = NSURL.fileURL(withPath: expandedLauncherLogPath, isDirectory: true)
        dialog.title = "Choose images folder"
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false
        dialog.showsResizeIndicator = true
        if(dialog.runModal() == NSApplication.ModalResponse.OK){
            placeDirectory = dialog.directoryURL!
        }
    }
    
    func setPlaceDirectory(defaults:UserDefaults){
        let defaultDirectory = defaults.url(forKey: "defaultDirectory")
        if(defaultDirectory != nil){
            placeDirectory = defaultDirectory!
        }
        else{
            getUserSelectedPlaceDirectory()
        }
        
        //buildPngContents(placeDirectory: placeDirectory)
        place.buildPngContents(placeDirectory: placeDirectory)
        
        if(place.getContentsCount() > 0){
            imageSlider.maxValue = Double(place.getContentsCount() - 1)
            defaults.set(placeDirectory, forKey: "defaultDirectory")
        }
        else{
            defaults.set(nil, forKey:"defaultDirectory")
            setPlaceDirectory(defaults: defaults)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let defaultFPS = defaults.integer(forKey: "startingFPS")
        let defaultImageIndex = defaults.integer(forKey: "startingIndex")

        setPlaceDirectory(defaults: defaults)
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.setPlace(placeToSet:place)
        if(defaultFPS > 0){
            slideShowFPS.integerValue = defaultFPS
        }
        if(defaultImageIndex > 0){
            place.setContentsIndex(index: defaultImageIndex)
            imageSlider.integerValue = defaultImageIndex
        }
        place.delegate = self
        updateUI(index: place.getContentsIndex())
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            self.updateFrameVisibleRect()
            return $0
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFrameVisibleRect),
            name: NSScrollView.didLiveScrollNotification,
            object: placeScrollView
        )
    }
    
    override func viewDidAppear() {
        updateFrameVisibleRect()
    }

    @objc func updateFrameVisibleRect(){
        let vr:NSRect = placeImage.visibleRect
        originX.integerValue = Int(vr.origin.x)
        originY.integerValue = Int(vr.origin.y)
        width.integerValue = Int(vr.width)
        height.integerValue = Int(vr.height)
        print("Currently Visible portion: \(String(describing: placeImage.visibleRect.debugDescription)).")
    }
    
    func updateUI(index:Int){
        updateCurrentIndexLabel(index: index)
        updateImageWithContent(index: index)
        updateFrameVisibleRect()
    }
    
    func updateSlideShowLabel(isSlideShowGoing:Bool){
        if isSlideShowGoing{
            btnSlideShow.title = "Stop Slideshow"
        }
        else{
            btnSlideShow.title = "Start Slideshow"
        }
    }
    
    func updateCurrentIndexLabel(index:Int){
        imageSlider.integerValue = index
        currentIndex.integerValue = index
        totalCount.integerValue = place.getContentsCount()
    }
    
    func updateImageWithContent(index:Int){
        let imagePath = place.getContentAtIndex(index: index)
        let image = NSImage(contentsOf: imagePath)
        placeImage.image = image
        
    }
    
    fileprivate func toggleSlideShow() {
        place.toggleSlideShow(slideShowFPS:slideShowFPS.integerValue)
        updateSlideShowLabel(isSlideShowGoing: place.getIsSlideShowGoing())
    }
    
    func goToNextImage(){
        place.incrementContentsIndex()
        updateUI(index: place.getContentsIndex())
    }
    
    func goToPreviousImage(){
        place.decrementContentsIndex()
        updateUI(index: place.getContentsIndex())
    }
    
    func goToImageAtIndex(index:Int){
        place.setContentsIndex(index: index)
        updateUI(index: place.getContentsIndex())
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
extension MainViewController:PlaceSlideshowProtocol{
    func currentContents(_ place: Place, index:Int){
        updateUI(index:index)
    }
}

