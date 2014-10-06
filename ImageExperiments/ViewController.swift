//
//  ViewController.swift
//  ImageExperiments
//
//  Created by Jannis Muething on 10/2/14.
//  Copyright (c) 2014 Jannis Muething. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lowerImageView: UIImageView!
    
    @IBOutlet weak var upperImageView: UIImageView!
    
    var filter : Filter?
    
    var image : UIImage = UIImage(named: "sharptest")
    
    var intensityValue = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.upperImageView.image = image
        
        if let aFilter = filter {
            self.lowerImageView.image = aFilter(image)
        }
        
//        var imgArray = cgImageToImageArray(UIImage(named: "200").CGImage)
//        imgArray[0][0] = [255,0,0, 255]
//        imgArray[1][1] = [0,255,0, 255]
//        imgArray[2][2] = [0,0,255, 255]
//
//        
//        self.lowerImageView.image = (UIImage(CGImage:imageArrayToCgImage(imgArray), scale:2, orientation: .Up))
    }

    @IBAction func intensitySliderDidChange(sender: AnyObject) {
        if let slider = sender as? UISlider {
            
            let cvalue = Int(slider.value)
            if cvalue != intensityValue {
                intensityValue = cvalue
                self.lowerImageView.image = (filter! * intensityValue)(image)
                slider.value = Float(intensityValue)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }
}

