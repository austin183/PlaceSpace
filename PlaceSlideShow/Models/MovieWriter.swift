//from https://gist.githubusercontent.com/JaleelNazir/ce17ac24ec99636a230b3de8a98d7000/raw/365bf085af2912e1c57e96261e9e8cb561445d6d/MovieWriter.swift

import AppKit
import AVFoundation

protocol MovieWriterProtocol{
    func currentProgress(_ section:String, current:Int, total:Int)
}
class MovieWriter: NSObject {
    var delegate:MovieWriterProtocol?
    private var imageHandler:ImageHandler = ImageHandler()
    private var start:Int = 0
    private var stop:Int = 0
    private var skipFrames:Int = 0
    private var exportFPS:Int = 0
    private var xValue:Int = 0
    private var yValue:Int = 0
    private var width:Int = 0
    private var height:Int = 0
    private var useCrop:Bool = false
    
    func setRange(start:Int, stop:Int, skipFrames:Int, exportFPS:Int){
        self.start = start
        self.stop = stop
        self.skipFrames = skipFrames
        self.exportFPS = exportFPS
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
    
    func writeMovie(destinationPath:URL, place:Place, scale:Double, backingScale:CGFloat){
        //do everything to build the things to pass to writeImagesAsMovie
        
        var images:[URL] = []
        for index:Int in start...stop{
            if (skipFrames == 0 || index % skipFrames == 0  || index == stop) {
                let imageURL = place.getContentAtIndex(index: index)
                images.append(imageURL)
            }
        }
        
        writeImagesAsMovie(images, videoPath: destinationPath.path, scale:scale, videoFPS: Int32(exportFPS))
    }
    
    func writeImagesAsMovie(_ allImages: [URL], videoPath: String, scale:Double, videoFPS: Int32) {
        let finalScale = scale
        let scaledSize:NSSize = NSSize(width: CGFloat(width) * CGFloat(finalScale), height: CGFloat(height) * CGFloat(finalScale))
        let cgScaledSize:CGSize = CGSize(width: CGFloat(width) * CGFloat(finalScale), height: CGFloat(height) * CGFloat(finalScale))
        // Create AVAssetWriter to write video
        let imageCount = allImages.count
        let section:String = "Building the movie file"
        delegate?.currentProgress(section, current: 0, total: imageCount)
        guard let assetWriter = createAssetWriter(videoPath, size: cgScaledSize) else {
            print("Error converting images to video: AVAssetWriter not created")
            delegate?.currentProgress("error converting images to video", current: 0, total: 0)
            return
        }
        
        // If here, AVAssetWriter exists so create AVAssetWriterInputPixelBufferAdaptor
        let writerInput = assetWriter.inputs.filter{ $0.mediaType == AVMediaType.video }.first!
        let sourceBufferAttributes : [String : AnyObject] = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB) as AnyObject,
            kCVPixelBufferWidthKey as String : cgScaledSize.width as AnyObject,
            kCVPixelBufferHeightKey as String : cgScaledSize.height as AnyObject,
            ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        // Start writing session
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: kCMTimeZero)
        if (pixelBufferAdaptor.pixelBufferPool == nil) {
            print("Error converting images to video: pixelBufferPool nil after starting session")
            delegate?.currentProgress("error converting images to video", current: 0, total: 0)
            return
        }
        
        // -- Create queue for <requestMediaDataWhenReadyOnQueue>
        let mediaQueue = DispatchQueue(label: "mediaInputQueue", attributes: [])
        
        // -- Set video parameters
        let frameDuration = CMTimeMake(1, videoFPS)
        var frameCount = 0
        
        // -- Add images to video
        let numImages = allImages.count
        writerInput.requestMediaDataWhenReady(on: mediaQueue, using: { () -> Void in
            // Append unadded images to video but only while input ready
            while (writerInput.isReadyForMoreMediaData && frameCount < numImages) {
                let lastFrameTime = CMTimeMake(Int64(frameCount), videoFPS)
                let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                
                // Convert an NSImage to CGImage, fitting within the specified rect
                // You can replace `&rect` with nil
                autoreleasepool{
                    let image = NSImage(contentsOf: allImages[frameCount])
                    
                    let cgImage:CGImage = self.getCGImage(image:image!)
                    
                    let imageToWrite = NSImage(cgImage: cgImage, size: scaledSize)
                    if !self.appendPixelBufferForImageAtURL(imageToWrite, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                        self.delegate?.currentProgress("error converting images to video", current: 0, total: 0)
                        print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
                        return
                    }
                }

                frameCount += 1
                self.delegate?.currentProgress(section, current: frameCount, total: imageCount)
            }
            
            // No more images to add? End video.
            if (frameCount >= numImages) {
                writerInput.markAsFinished()
                assetWriter.finishWriting {
                    if (assetWriter.error != nil) {
                        self.delegate?.currentProgress("error converting images to video", current: 0, total: 0)
                        print("Error converting images to video: \(String(describing: assetWriter.error))")
                    }
                }
            }
        })
    }
    
    private func getCGImage(image:NSImage) -> CGImage{
        let cgImage:CGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        if(self.useCrop){
            return self.imageHandler.cropImage(image: cgImage, originX: CGFloat(self.xValue), originY: CGFloat(self.yValue), width: CGFloat(self.width), height: CGFloat(self.height))
        }
        return cgImage
    }
    
    
    func createAssetWriter(_ path: String, size: CGSize) -> AVAssetWriter? {
        // Convert <path> to NSURL object
        let pathURL = URL(fileURLWithPath: path)
        
        // Return new asset writer or nil
        do {
            // Create asset writer
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: pathURL.path){
                try fileManager.removeItem(at: pathURL)
            }
            let newWriter = try AVAssetWriter(outputURL: pathURL, fileType: AVFileType.mp4)
            
            // Define settings for video input
            let videoSettings: [String : AnyObject] = [
                AVVideoCodecKey  : AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey  : size.width as AnyObject,
                AVVideoHeightKey : size.height as AnyObject,
                ]
            
            // Add video input to writer
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            newWriter.add(assetWriterVideoInput)
            
            // Return writer
            //print("Created asset writer for \(size.width)x\(size.height) video")
            return newWriter
        } catch {
            delegate?.currentProgress("error converting images to video", current: 0, total: 0)
            NSLog("Error: Failed to allocate pixel buffer from pool")
            return nil
        }
    }
    
    
    func appendPixelBufferForImageAtURL(_ image: NSImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = false
        
        autoreleasepool {
            if  let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity:1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                if let pixelBuffer = pixelBufferPointer.pointee , status == 0 {
                    fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                    appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    pixelBufferPointer.deinitialize(count:1)
                } else {
                    delegate?.currentProgress("error converting images to video", current: 0, total: 0)
                    NSLog("Error: Failed to allocate pixel buffer from pool")
                }
                
                pixelBufferPointer.deallocate()
            }
        }
        
        return appendSucceeded
    }
    
    
    func fillPixelBufferFromImage(_ image: NSImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create CGBitmapContext
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            )!
        
        // Draw image into context
        let drawCGRect = CGRect(x:0, y:0, width:image.size.width, height:image.size.height)
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        context.draw(cgImage, in: drawCGRect)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
}



