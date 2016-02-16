import ImageIO
import MobileCoreServices


@objc public class GifGenerator: NSObject {
    
    /**
     Generate a GIF using a set of images
     You can specify the loop count and the delays between the frames.
     
     :param: images an array of images
     :param: repeatCount the repeat count, defaults to 0 which is infinity
     :param: frameDelay an delay in seconds between each frame
     :param: callback set a block that will get called when done, it'll return with data and error, both which can be nil
     */
    public func generateGifFromImages(images:[UIImage], repeatCount: Int = 0, frameDelay: NSTimeInterval, destinationURL: NSURL, callback:(data: NSData?, error: NSError?) -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            
            if let imageDestination = CGImageDestinationCreateWithURL(destinationURL, kUTTypeGIF, images.count, nil) {
                
                let frameProperties:CFDictionaryRef = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
                let gifProperties:CFDictionaryRef = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: repeatCount]]
                
                for image in images {
                    CGImageDestinationAddImage(imageDestination, image.CGImage!, frameProperties)
                }
                
                CGImageDestinationSetProperties(imageDestination, gifProperties)
                if CGImageDestinationFinalize(imageDestination) {
                    
                    print("animated GIF file created at ", destinationURL)
                    
                    do {
                        if let path = destinationURL.path {
                            let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
                            
                            if let _attr = attr {
                                print("FILE SIZE: ", NSByteCountFormatter.stringFromByteCount(Int64(_attr.fileSize()), countStyle: .File))
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

    private func errorFromString(string: String, code: Int = -1) -> NSError {
        let dict = [NSLocalizedDescriptionKey: string]
        return NSError(domain: "org.cocoapods.GIFGenerator", code: code, userInfo: dict)
    }
}
