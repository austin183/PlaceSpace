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
    
    func writeGif(destinationPath:URL, place:Place, scale:Double){
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
            var finalImage:CGImage = cgImage
            if(useCrop){
                cropRect = NSMakeRect(CGFloat(xValue), CGFloat(yValue), CGFloat(width), CGFloat(height))
                finalImage = cgImage.cropping(to: cropRect!)!
            }
            if(scale != 1.0){
                finalImage = getResizedImage(image: finalImage, scale: scale)!
            }
            CGImageDestinationAddImage(destinationGIF, finalImage, properties as CFDictionary)
        }
        
        // Write the GIF file to disk
        CGImageDestinationFinalize(destinationGIF)
    }
    
    private func getResizedImage(image:CGImage, scale:Double) -> CGImage?{
        let imageToScale = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        let newWidth = CGFloat(Double(image.width) * scale)
        let newHeight = CGFloat(Double(image.height) * scale)
        let resizedRect = NSRect(x: 0, y: 0, width: newWidth, height: newHeight)
        var resizedCGRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        let newSize = NSSize(width: newWidth, height: newHeight)
        guard let representation = imageToScale.bestRepresentation(for: resizedRect, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: newSize, flipped: false, drawingHandler: { (_) -> Bool in
            return representation.draw(in: resizedRect)
        })
        
        return image.cgImage(forProposedRect: &resizedCGRect, context: nil, hints: nil)!
    }
}
