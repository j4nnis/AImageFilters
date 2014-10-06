//
//  ImagePlayground.swift
//  ImageExperiments
//
//  Created by Jannis Muething on 05.10.14.
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

import Foundation
import CoreGraphics

/**
    It alomost goes without saying: The methods in this file are intented for academic purposes only. If you for example want to do the matrix convolution math yourself or something similar.

    :imageArray: A NxM matrix of arrays representing the red, green, blue and alpha channel (each gets a value between 0 and 255)
    
    :return: The image reference corresponding to the array supplied
*/
func imageArrayToCgImage(imageArray:[[[UInt8]]]) -> CGImageRef {
    var colorSpace = CGColorSpaceCreateDeviceRGB()
    
    var context = CGBitmapContextCreate(nil, UInt(imageArray[0].count), UInt(imageArray.count), 8, 0, colorSpace, CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.toRaw()));
    
    for row in 0 ..< imageArray.count {
        for column in 0 ..< imageArray[0].count {
            CGContextSetRGBFillColor(context, CGFloat(imageArray[row][column][0]), CGFloat(imageArray[row][column][1]), CGFloat(imageArray[row][column][2]), CGFloat(imageArray[row][column][3]))
            
            CGContextFillRect(context, CGRectMake(CGFloat(row), CGFloat(column), 1, 1))
        }
    }
    
    return CGBitmapContextCreateImage(context)
}

/**
    It alomost goes without saying: The methods in this file are intented for academic purposes only. If you for example want to do the matrix convolution math yourself or something similar.


    :img: the CGImageRef (UIImage.CGImage gets you one from a UIImage)

    :return: a NxM matrix of arrays representing the red, green, blue and alpha channel (each gets a value between 0 and 255)
*/

func cgImageToImageArray(img : CGImageRef) -> [[[UInt8]]] {
    
    let inProvider = CGImageGetDataProvider(img)
    let bitmapData = CGDataProviderCopyData(inProvider)
    
    let width = CGImageGetWidth(img)
    let height = CGImageGetHeight(img)
    let bytesPerRow = CGImageGetBytesPerRow(img)
    let bitsPerComponent = CGImageGetBitsPerComponent(img)
    let bitsPerPixel = CGImageGetBitsPerPixel(img)
    
    let bytesPerPixel = bitsPerPixel / bitsPerComponent
    
    var dataPtr : UnsafePointer<UInt8> = CFDataGetBytePtr(bitmapData)
    
    var rgbaArray = [[[UInt8]]]()
    
    for row in (0 ..< height) {
        rgbaArray.append([])
        for column in (0 ..< width) {
            
            rgbaArray[Int(row)].append([])
            let p = Int(row*bytesPerRow+column*bytesPerPixel)
            for x : Int in (0 ..< Int(bytesPerPixel)) {
                let value = dataPtr[p+x]
                rgbaArray[Int(row)][Int(column)].append(value)
            }
        }
    }
    return rgbaArray
}