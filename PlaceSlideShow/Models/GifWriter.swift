//
//  GifWriter.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/20/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Foundation
import Cocoa
protocol GifWritingProtocol{
    func currentIndexToWrite(_ gifWriter: GifWriter, currentIndex:Int, count:Int)
}
class GifWriter{
    private var start:Int = 0
    private var stop:Int = 0
    private var skipFrames:Int = 0
    private var gifFPS:Int = 0
    private var xValue:Int = 0
    private var yValue:Int = 0
    private var width:Int = 0
    private var height:Int = 0
    private var useCrop:Bool = false
    
    func setRange(start:Int, stop:Int, skipFrames:Int, gifFPS:Int){
        self.start = start
        self.stop = stop
        self.skipFrames = skipFrames
        self.gifFPS = gifFPS
    }
    
    func setCropRectangleCoordinates(yValue:Int, xValue:Int, width:Int, height:Int){
        if(width > 0 || height > 0){
            self.xValue = xValue
            self.yValue = yValue
            self.width = width
            self.height = height
            self.useCrop = true
        }
    }
    
    func writeGif(destinationPath:URL, place:Place){
        var images:[URL] = []
        for index:Int in start...stop{
            if (skipFrames == 0 || index % skipFrames == 0) {
                let imageURL = place.getContentAtIndex(index: index)
                images.append(imageURL)
            }
        }

        let destinationGIF = CGImageDestinationCreateWithURL(destinationPath as CFURL, kUTTypeGIF, images.count, nil)!
        
        // The final size of your GIF. This is an optional parameter
        var rect = NSMakeRect(0, 0, 1000, 1000)
        var cropRect:NSRect?
        if(useCrop){
            cropRect = NSMakeRect(CGFloat(xValue), CGFloat(yValue), CGFloat(width), CGFloat(height))
        }
        
        // This dictionary controls the delay between frames
        // If you don't specify this, CGImage will apply a default delay
        let properties = [
            (kCGImagePropertyGIFDictionary as String): [(kCGImagePropertyGIFDelayTime as String): 1.0/Double(gifFPS)]
        ]
        
        for img in images {
            // Convert an NSImage to CGImage, fitting within the specified rect
            // You can replace `&rect` with nil
            let image = NSImage(contentsOf: img)
            let cgImage = image!.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
            if(useCrop){
                let croppedImage = cgImage.cropping(to: cropRect!)
                CGImageDestinationAddImage(destinationGIF, croppedImage!, properties as CFDictionary)
            }
            else{
                CGImageDestinationAddImage(destinationGIF, cgImage, properties as CFDictionary)
            }
        }
        
        // Write the GIF file to disk
        CGImageDestinationFinalize(destinationGIF)
    }
}
