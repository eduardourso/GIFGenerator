![.GIFGenerator](http://i.imgur.com/IDEiCl2.png?1)

[![CI Status](http://img.shields.io/travis/Eduardo Urso/GIFGenerator.svg?style=flat)](https://travis-ci.org/Eduardo Urso/GIFGenerator)
[![Version](https://img.shields.io/cocoapods/v/GIFGenerator.svg?style=flat)](http://cocoapods.org/pods/GIFGenerator)
[![License](https://img.shields.io/cocoapods/l/GIFGenerator.svg?style=flat)](http://cocoapods.org/pods/GIFGenerator)
[![Platform](https://img.shields.io/cocoapods/p/GIFGenerator.svg?style=flat)](http://cocoapods.org/pods/GIFGenerator)

### Add to your project
There are 2 ways you can add .GIFGenerator to your project:

### Manual installation
Simply import the 'GIFGenerator' folder into your project then import the classes that you want to use.

#### Obj-C
```objective-c
#import "GIFGenerator.h"
``` 
#### Swift
```swift
import GIFGenerator
``` 

### Avaliable in CocoaPods
GIFGenerator is available through [CocoaPods](https://cocoapods.org) See the "[Getting Started](http://guides.cocoapods.org/syntax/podfile.html)" guide for more information.

To install it, simply add the following line to your Podfile:

#### Podfile
```ruby
platform :ios, '8.0'
pod "GIFGenerator"
```

### Practical use
```swift
let gifGenerator = GifGenerator()
gifGenerator.generateGifFromImages(imagesArray, frameDelay: 0.5, destinationURL: url, callback: { (data, error) -> () in
  //returns a gif file.
})
```
This generates a GIF from provided images.

The library is lightweight and very straight forward. Once you have the array of images, pass it to GIFGenerator alongside the url and frame delay. 
Let me explain those for you: 
```
images - array of images that will compose the GIF file!
frameDelay  -  is the amount of time between each frame in the GIF.
destinationURL  - is the url where the GIF file will be stored.
```
I recommend you to play with those parameters to see how it can affect the GIF file.

### Example Project
To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Author
Eduardo Urso, eduardourso@gmail.com

### License
GIFGeneraor is available under the MIT license. See the LICENSE file for more info.
