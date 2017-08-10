import ImageIO
import MobileCoreServices
import AVFoundation


@objc public class GifGenerator: NSObject {
    
    var cmTimeArray:[NSValue] = []
    var framesArray:[UIImage] = []
    
    /**
     Generate a GIF using a set of images
     You can specify the loop count and the delays between the frames.
     
     :param: imagesArray an array of images
     :param: repeatCount the repeat count, defaults to 0 which is infinity
     :param: frameDelay an delay in seconds between each frame
     :param: callback set a block that will get called when done, it'll return with data and error, both which can be nil
     */
    public func generateGifFromImages(imagesArray: [UIImage], repeatCount: Int = 0, frameDelay: TimeInterval, destinationURL: NSURL, callback:(_ data: NSData?, _ error: NSError?) -> ()) {
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            
            if let imageDestination = CGImageDestinationCreateWithURL(destinationURL, kUTTypeGIF, imagesArray.count, nil) {
                
                let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
                let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: repeatCount]]

                for image in imagesArray {
                    CGImageDestinationAddImage(imageDestination, image.cgImage!, frameProperties as CFDictionary)
                }
                
                CGImageDestinationSetProperties(imageDestination, gifProperties as CFDictionary)
                if CGImageDestinationFinalize(imageDestination) {
                    
                    print("animated GIF file created at ", destinationURL)
                    
                    do {
                        if let path = destinationURL.path {
                            let attr = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
                            
                            if let _attr = attr {
                                print("FILE SIZE: ", ByteCountFormatter.string(fromByteCount: Int64(_attr.fileSize()), countStyle: .File))
                            }
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                    
                    callback(data: NSData(contentsOfURL: destinationURL), error: nil)
                } else {
                    callback(data: nil, error: self.errorFromString("Couldn't create the final image"))
                }
            }
        }
    }
    
    /**
     Generate a GIF using a set of video file (NSURL)
     You can specify the loop count and the delays between the frames.
     
     :param: videoURL an url where you video file is stored
     :param: repeatCount the repeat count, defaults to 0 which is infinity
     :param: frameDelay an delay in seconds between each frame
     :param: callback set a block that will get called when done, it'll return with data and error, both which can be nil
     */
    public func generateGifFromVideoURL(videoURL videoUrl:NSURL, repeatCount: Int = 0, framesInterval: Int, frameDelay: TimeInterval, destinationURL: NSURL, callback:(_ data: NSData?, _ error: NSError?) -> ()) {
        
        self.generateFrames(url: videoUrl, framesInterval: framesInterval) { (images) -> () in
            if let images = images {
                self.generateGifFromImages(imagesArray: images, repeatCount: repeatCount, frameDelay: frameDelay, destinationURL: destinationURL, callback: { (data, error) -> () in
                    self.cmTimeArray = []
                    self.framesArray = []
                    callback(data, error)
                })
            }
        }
    }
    
    // MARK: THANKS TO: http://stackoverflow.com/questions/4001755/trying-to-understand-cmtime-and-cmtimemake
   private func generateFrames(url: NSURL, framesInterval: Int, callback: @escaping (_ images: [UIImage]?) -> ()) {
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            self.generateCMTimesArrayOfFramesUsingAsset(framesInterval: framesInterval, asset: AVURLAsset(url: url as URL))
            
            var i = 0
            let test:AVAssetImageGeneratorCompletionHandler = { (_, im:CGImage?, _, result:AVAssetImageGeneratorResult, error:NSError?) in
                if(result == AVAssetImageGeneratorResult.Succeeded) {
                    print("Succeed")
                    if let image = im {
                        self.framesArray.append(UIImage(CGImage: image))
                    }
                } else if (result == AVAssetImageGeneratorResult.Failed) {
                    print("Failed with error")
                    callback(images: nil);
                } else if (result == AVAssetImageGeneratorResult.Cancelled) {
                    print("Canceled")
                    callback(images: nil);
                }
                i++
                if(i == self.cmTimeArray.count) {
                    //Thumbnail generation completed
                    callback(images: self.framesArray)
                }
            }
            let generator = AVAssetImageGenerator(asset: AVAsset(url: url as URL))
            generator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;
            generator.appliesPreferredTrackTransform = true;
            generator.requestedTimeToleranceBefore = kCMTimeZero;
            generator.requestedTimeToleranceAfter = kCMTimeZero;
            generator.maximumSize = CGSize(width: 200, height: 200);
            
            generator.generateCGImagesAsynchronouslyForTimes(self.cmTimeArray, completionHandler: test)
        }
    }
    
   private func generateCMTimesArrayOfAllFramesUsingAsset(asset:AVURLAsset) {
        if cmTimeArray.count > 0 {
            cmTimeArray.removeAll()
        }
        
        for (var t:Int64 = 0; t < asset.duration.value; t++) {
            let thumbTime = CMTimeMake(t, asset.duration.timescale)
            let value = NSValue(CMTime: thumbTime)
            cmTimeArray.append(value)
        }
    }
    
    private func generateCMTimesArrayOfFramesUsingAsset(framesInterval:Int, asset:AVURLAsset) {
        
        let videoDuration = Int(ceilf((Float(Int(asset.duration.value)/Int(asset.duration.timescale)))))
        
        if cmTimeArray.count > 0 {
            cmTimeArray.removeAll()
        }
        
        for (var t = 0; t < videoDuration; t++) {
            let tempInt = Int64(t)
            let tempCMTime = CMTimeMake(tempInt, asset.duration.timescale)
            let interval = Int32(framesInterval)
            
            for (var j = 1; j < framesInterval+1; j++) {
                let newCMtime = CMTimeMake(Int64(j), interval)
                let addition = CMTimeAdd(tempCMTime, newCMtime)
                cmTimeArray.append(NSValue(CMTime: addition))
            }
        }
    }

    private func errorFromString(string: String, code: Int = -1) -> NSError {
        let dict = [NSLocalizedDescriptionKey: string]
        return NSError(domain: "org.cocoapods.GIFGenerator", code: code, userInfo: dict)
    }
}
