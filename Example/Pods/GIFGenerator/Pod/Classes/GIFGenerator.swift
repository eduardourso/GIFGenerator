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
    public func generateGifFromImages(imagesArray: [UIImage],
                                      repeatCount: Int = 0,
                                      frameDelay: TimeInterval, 
                                      destinationURL: URL, 
                                      callback: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            
            if let imageDestination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeGIF, imagesArray.count, nil) {
                
                let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
                let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: repeatCount]]

                for image in imagesArray {
                    CGImageDestinationAddImage(imageDestination, image.cgImage!, frameProperties as CFDictionary)
                }
                
                CGImageDestinationSetProperties(imageDestination, gifProperties as CFDictionary)
                if CGImageDestinationFinalize(imageDestination) {
                    
                    print("animated GIF file created at ", destinationURL)
                    
                    do {
                        let attr = try FileManager.default.attributesOfItem(atPath: destinationURL.path) as NSDictionary
                        let data = try Data(contentsOf: destinationURL)
                        print("FILE SIZE: ", ByteCountFormatter.string(fromByteCount: Int64(attr.fileSize()), countStyle: .file))
                        callback(data, nil)
                    } catch {
                        print("Error: \(error)")
                        callback(nil, error)
                    }
                } else {
                    callback(nil, self.errorFromString(string: "Couldn't create the final image"))
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
    public func generateGifFromVideoURL(videoURL videoUrl: URL, repeatCount: Int = 0, framesInterval: Int, frameDelay: TimeInterval, destinationURL: URL, callback: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        
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
   private func generateFrames(url: URL, framesInterval: Int, callback: @escaping (_ images: [UIImage]?) -> ()) {
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            self.generateCMTimesArrayOfFramesUsingAsset(framesInterval: framesInterval, asset: AVURLAsset(url: url as URL))
            
            var i = 0
            let test:AVAssetImageGeneratorCompletionHandler = { (_ :CMTime, im: CGImage?, time: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) in
                if(result == AVAssetImageGeneratorResult.succeeded) {
                    print("Succeed")
                    if let image = im {
                        self.framesArray.append(UIImage(cgImage: image))
                    }
                } else if (result == AVAssetImageGeneratorResult.failed) {
                    print("Failed with error")
                    callback(nil)
                } else if (result == AVAssetImageGeneratorResult.cancelled) {
                    print("Canceled")
                    callback(nil)
                }
                i += 1
                if(i == self.cmTimeArray.count) {
                    callback(self.framesArray)
                }
            } as! AVAssetImageGeneratorCompletionHandler
            let generator = AVAssetImageGenerator(asset: AVAsset(url: url as URL))
            generator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;
            generator.appliesPreferredTrackTransform = true;
            generator.requestedTimeToleranceBefore = kCMTimeZero;
            generator.requestedTimeToleranceAfter = kCMTimeZero;
            generator.maximumSize = CGSize(width: 200, height: 200);
            
            generator.generateCGImagesAsynchronously(forTimes: self.cmTimeArray, completionHandler: test)
        }
    }
    
    private func generateCMTimesArrayOfAllFramesUsingAsset(asset:AVURLAsset) {
        if cmTimeArray.count > 0 {
            cmTimeArray.removeAll()
        }

        for time in 0 ..< asset.duration.value {
            let thumbTime = CMTime(seconds: Double(time), preferredTimescale: asset.duration.timescale)
            cmTimeArray.append(thumbTime as NSValue)
        }
    }
    
    private func generateCMTimesArrayOfFramesUsingAsset(framesInterval:Int, asset:AVURLAsset) {
        
        let videoDuration = Int(ceilf((Float(Int(asset.duration.value)/Int(asset.duration.timescale)))))
        
        if cmTimeArray.count > 0 {
            cmTimeArray.removeAll()
        }
        
        for t in 0 ..< videoDuration {
            let tempInt = Int64(t)
            let tempCMTime = CMTimeMake(tempInt, asset.duration.timescale)
            let interval = Int32(framesInterval)
            
            for j in 1 ..< framesInterval+1 {
                let newCMtime = CMTime(seconds: Double(j), preferredTimescale: interval)
                let addition = CMTimeAdd(tempCMTime, newCMtime)
                cmTimeArray.append(addition as NSValue)
            }
        }
    }

    private func errorFromString(string: String, code: Int = -1) -> NSError {
        let dict = [NSLocalizedDescriptionKey: string]
        return NSError(domain: "org.cocoapods.GIFGenerator", code: code, userInfo: dict)
    }
}
