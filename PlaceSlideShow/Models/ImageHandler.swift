//
//  ImageHandler.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/30/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Foundation
import Cocoa
class ImageHandler {
    func getResizedImage(image:CGImage, scale:Double) -> CGImage?{
        
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
    
    func cropImage(image:CGImage, originX:CGFloat, originY:CGFloat, width:CGFloat, height:CGFloat) -> CGImage{
        let cropRect:NSRect = NSMakeRect(originX, originY, width, height)
        return image.cropping(to: cropRect)!
    }
    
    
    
}
