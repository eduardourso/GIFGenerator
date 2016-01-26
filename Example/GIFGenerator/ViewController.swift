//
//  ViewController.swift
//  GIFGenerator
//
//  Created by Eduardo Urso on 01/26/2016.
//  Copyright (c) 2016 Eduardo Urso. All rights reserved.
//

import UIKit
import GIFGenerator
import FLAnimatedImage

class ViewController: UIViewController {
    
    let gifGenerator = GifGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let images:[UIImage] = [UIImage(named: "homer-simpson.jpg")!, UIImage(named: "homer-simpson2.jpg")!]
        let images2:[UIImage] = [UIImage(named: "bart1.jpg")!, UIImage(named: "bart2.jpg")!, UIImage(named: "bart3.jpg")!, UIImage(named: "bart4.jpg")!, UIImage(named: "bart5.jpg")!]
        
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        if let destinationPath :String = documentsPath.stringByAppendingString("/animated.gif") {
            
            gifGenerator.generateGifFromImages(images2, frameDelay: 0.5, destinationURL: NSURL(fileURLWithPath: destinationPath), callback: { (data, error) -> () in
                if error == nil {
                    if let data = data {
                        let image = FLAnimatedImage(animatedGIFData: data)
                        let imageView = FLAnimatedImageView()
                        imageView.animatedImage = image
                        imageView.frame = CGRectMake(0, 0, image.size.width/2, image.size.height/2)
                        imageView.center = self.view.center
                        self.view.addSubview(imageView)
                    }
                }
                
            })
    
        }
    }
}

