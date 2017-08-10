//
//  ViewController.swift
//  GIFGenerator
//
//  Created by Eduardo Urso on 01/26/2016.
//  Copyright (c) 2016 Eduardo Urso. All rights reserved.
//

import UIKit
import GIFGenerator

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var resultLabel: UILabel!

    let gifGenerator = GifGenerator()
    private let imageView = UIImageView()
    
    let images2:[UIImage] = [UIImage(named: "bart1.jpg")!, UIImage(named: "bart2.jpg")!, UIImage(named: "bart3.jpg")!, UIImage(named: "bart4.jpg")!, UIImage(named: "bart5.jpg")!]
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    @IBAction func gifFromImages(_ sender: AnyObject) {
        self.generateAnimatedImage(images2)
    }
    
    @IBAction func gifFromVideo(_ sender: AnyObject) {
        self.generateAnimatedGifFromVideo()
    }
    
    func generateAnimatedImage(_ imageArray: [UIImage]) {

        let destinationPath = documentsPath + "/imageAnimated.gif"
        
        gifGenerator.generateGifFromImages(imagesArray: imageArray, frameDelay: 0.5, destinationURL: URL(fileURLWithPath: destinationPath), callback: { (data, error) -> () in
            print("Gif generated under \(destinationPath)")
            DispatchQueue.main.async {
                self.resultLabel.text = "Gif generated under \(destinationPath)"
            }
        })
    }
    
    func generateAnimatedGifFromVideo() {

        let destinationPath = documentsPath + "/videoAnimated.gif"
        
        if let url = Bundle.main.url(forResource: "myvideo", withExtension: "mp4") {
            
            gifGenerator.generateGifFromVideoURL(videoURL: url, framesInterval: 10, frameDelay: 0.2, destinationURL: URL(fileURLWithPath: destinationPath), callback: { (data, error) -> () in
                print("Gif generated under \(destinationPath)")
                DispatchQueue.main.async {
                    self.resultLabel.text = "Gif generated under \(destinationPath)"
                }
            })
        } else {
            print("file not found")
        }
    }
}

