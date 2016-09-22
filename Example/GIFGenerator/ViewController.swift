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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imageView = FLAnimatedImageView()
    let gifGenerator = GifGenerator()
    
    let images2:[UIImage] = [UIImage(named: "bart1.jpg")!, UIImage(named: "bart2.jpg")!, UIImage(named: "bart3.jpg")!, UIImage(named: "bart4.jpg")!, UIImage(named: "bart5.jpg")!]
    
    @IBAction func gifFromImages(_ sender: AnyObject) {
        self.generateAnimatedImage(images2)
    }
    
    @IBAction func gifFromVideo(_ sender: AnyObject) {
        self.generateAnimatedGifFromVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.imageView)
    }
    
    func generateAnimatedImage(_ imageArray: [UIImage]) {
    
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
        let destinationPath :String = documentsPath + "/animated.gif"
        
        gifGenerator.generateGifFromImages(imagesArray: imageArray, frameDelay: 0.5, destinationURL: URL(fileURLWithPath: destinationPath), callback: { (data, error) -> () in
            let image = FLAnimatedImage(animatedGIFData: data)
            self.imageView.animatedImage = image
            self.imageView.frame = CGRect(x: 0, y: 0, width: (image?.size.width)!/2, height: (image?.size.height)!/2)
            self.imageView.center = self.view.center
        })
    }
    
    func generateAnimatedGifFromVideo() {
        
        let documentsPath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
        let destinationPath :String = documentsPath + "/animated.gif"
        
        if let url = Bundle.main.url(forResource: "myvideo", withExtension: "mp4"){
            
            gifGenerator.generateGifFromVideoURL(videoURL: url, framesInterval: 10, frameDelay: 0.2, destinationURL: URL(fileURLWithPath: destinationPath), callback: { (data, error) -> () in
                if let image = FLAnimatedImage(animatedGIFData: data) {
                    self.imageView.animatedImage = image
                    self.imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                    self.imageView.center = self.view.center
                }
            })
        } else {
            print("file not found")
        }
    }
}

