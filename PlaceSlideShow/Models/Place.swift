//
//  Place.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/18/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Foundation

protocol PlaceSlideshowProtocol{
    func currentContents(_ place: Place, index:Int)
}

class Place{
    var timer: Timer? = nil
    private var pngContentsSorted:[String] = []
    private var placeDirectory:URL = URL(fileURLWithPath:"")
    private var contentsIndex:Int = 0
    private var contentsCount:Int = 0
    private var startTime:Int? = nil
    private var slideShowPositive:Bool = true
    private var isSlideShowGoing:Bool = false
    
    func buildPngContents(placeDirectory:URL) {
        let fileManager = FileManager.default
        self.placeDirectory = placeDirectory
        var contents:[String] = []
        do{
            contents = try fileManager.contentsOfDirectory(atPath: placeDirectory.path)
        }
        catch{
            print("Error")
        }
        pngContentsSorted = contents.filter{$0.range(of:".png") != nil}
        pngContentsSorted.sort()
        contentsCount = pngContentsSorted.count
    }
    
    func incrementContentsIndex() {
        contentsIndex = contentsIndex + 1
        if contentsIndex >= contentsCount{
            contentsIndex = 0 //It wraps back to the beginning
        }
    }
    
    func decrementContentsIndex() {
        contentsIndex = contentsIndex - 1
        if(contentsIndex < 0){
            contentsIndex = contentsCount - 1 //It wraps to the end
        }
    }
    
    func setContentsIndex(index:Int){
        if(index <= contentsCount){
            contentsIndex = index
        }
        else{
            contentsIndex = 0 //It sets it back to the beginning
        }
    }
    
    func getIsSlideShowGoing() -> Bool{
        return isSlideShowGoing
    }
    
    func getContentsIndex() -> Int{
        return contentsIndex
    }
    
    func getContentAtIndex(index:Int) -> URL{
        var currentIndex:Int = index
        if(currentIndex == contentsCount){
            currentIndex = currentIndex - 1
        }
        return placeDirectory.appendingPathComponent(pngContentsSorted[currentIndex])
    }
    
    func getContentsCount() -> Int{
        return contentsCount
    }
    
    func interpretInterval(interval:Double) -> Double{
        var toReturn:Double = interval
        slideShowPositive = true
        if(interval == 0){
            toReturn = 1
        }
        else if(interval < 0){
            slideShowPositive = false
            toReturn = interval * -1
        }
        return toReturn
    }
    
    private func convertFPSToTimeInterval(slideShowFPS:Int) -> Double{
        var fps:Double = Double(slideShowFPS)
        if(fps == 0){
            fps = 1
        }
        return Double(1 / fps)
    }
    
    func buildTimer(useInterval:Double) -> Timer{
        return Timer.scheduledTimer(timeInterval: useInterval,
                                   target: self,
                                   selector: #selector(doSlideShow),
                                   userInfo: nil,
                                   repeats: true)
    }
    
    func updateSlideShowInterval(slideShowFPS:Int){
        let timeInterval:Double = convertFPSToTimeInterval(slideShowFPS: slideShowFPS)
        let useInterval = interpretInterval(interval: timeInterval)
        if(startTime != nil && timer != nil){
            timer?.invalidate()
            timer = nil
            timer = buildTimer(useInterval: useInterval)
        }
    }
    
    func toggleSlideShow(slideShowFPS:Int){
        let timeInterval:Double = convertFPSToTimeInterval(slideShowFPS: slideShowFPS)
        let useInterval = interpretInterval(interval: timeInterval)
        if(timer == nil){
            startTime = 0
            isSlideShowGoing = true
            timer = buildTimer(useInterval: useInterval)
        }
        else{
            startTime = nil
            timer?.invalidate()
            timer = nil
            isSlideShowGoing = false
        }
        
    }
    
    var delegate:PlaceSlideshowProtocol?
    @objc dynamic func doSlideShow(){
        if(startTime == nil) {
            return
        }
        if(slideShowPositive){
            incrementContentsIndex()
        }
        else{
            decrementContentsIndex()
        }
        
        delegate?.currentContents(self, index: contentsIndex)
    }
}
