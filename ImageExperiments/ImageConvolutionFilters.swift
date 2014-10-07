//
//  ImageOperations.swift
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


import Foundation
import Accelerate
import UIKit

typealias Filter = UIImage -> UIImage

func edgeDetection1() -> Filter {
    return filterWithConvolutionMatrix([1,0,-1, 0,0,0, -1,0,-1], 3, 3, 1)
}

func edgeDetection2() -> Filter {
    return filterWithConvolutionMatrix([0,1,0, 1,-4,1, 0,1,0], 3, 3, 1)
}

func edgeDetection3() -> Filter {
    return filterWithConvolutionMatrix([-1,-1,-1, -1,8,-1, -1,-1,-1], 3, 3, 1)
}

func sharpen() -> Filter {
    return filterWithConvolutionMatrix([0,-1,0, -1,5,-1, 0,-1,0], 3, 3, 1)
}

func gaussBlur() -> Filter {
    return filterWithConvolutionMatrix([1,2,1 ,2,4,2 ,1,2,1], 3, 3, 16)
}

func unsharp() -> Filter {
    let unsharpKernel : [[Int16]] = [[1,4,6,4,1], [4,16,24,16,4], [6,24,-476,24,6], [4,16,24,16,4], [1,4,6,4,1]]
    return filterWithConvolutionMatrix(kernel: unsharpKernel, divisor: -256)
}

func boxBlur(boxSize:Int) -> Filter{
    return { image in
        let imageRef = image.CGImage
        
        var inProvider = CGImageGetDataProvider(imageRef)
        var inBitMapData = CGDataProviderCopyData(inProvider)

        
        var inBuffer: vImage_Buffer = vImage_Buffer(data: UnsafeMutablePointer(CFDataGetBytePtr(inBitMapData)), height: CGImageGetHeight(imageRef), width: CGImageGetWidth(imageRef), rowBytes: CGImageGetBytesPerRow(imageRef))
        
        var pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))

        var outBuffer = vImage_Buffer(data: pixelBuffer, height: CGImageGetHeight(imageRef), width: CGImageGetWidth(imageRef), rowBytes: CGImageGetBytesPerRow(imageRef))

        var error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, UInt32(kvImageEdgeExtend))
        
        let out = UIImage(fromvImageOutBuffer:outBuffer, scale: image.scale, orientation: .Up)
        
        free(pixelBuffer)
        
        return out
    }
}

/**
    Convenience method to create a new filter with a two dimensional array representing the convolution matrix to be applied.

    :param: kernel two dimensional array representing the convolution matrix.
    :param: divisor the divisor to be applied.

    :return: the filter
*/
func filterWithConvolutionMatrix(#kernel: Array<Array<Int16>>, #divisor:Int32) -> Filter {
    
    var input : [Int16] = kernel.reduce([Int16]()) { (var nArray:[Int16], row:[Int16]) -> Array<Int16> in
        var mutableNArray = nArray
        for i16 in row {
            mutableNArray.append(i16)
        }
        return mutableNArray
    }
    
    return filterWithConvolutionMatrix(input, UInt32( kernel[0].count ), UInt32( kernel.count ), divisor)
}

infix operator >|> { associativity left }

func >|> (filter1: Filter, filter2: Filter) -> Filter {
    return { image in
        return filter2(filter1(image))
    }
}

func * (lhs: Filter, rhs: Int) -> Filter {
    if (rhs > 1){
        return (lhs >|> lhs) * (rhs-1)
    } else {
        return lhs
    }
}

//MARK: private methods and extensions

private func filterWithConvolutionMatrix(kernel: Array<Int16>, width:UInt32, height:UInt32, divisor:Int32) -> Filter{
    return { image in
        let imageRef = image.CGImage
        
        let inProvider = CGImageGetDataProvider(imageRef)
        let inBitMapData = CGDataProviderCopyData(inProvider)
        
        var inBuffer: vImage_Buffer = vImage_Buffer(data: UnsafeMutablePointer(CFDataGetBytePtr(inBitMapData)), height: CGImageGetHeight(imageRef), width: CGImageGetWidth(imageRef), rowBytes: CGImageGetBytesPerRow(imageRef))
        
        var pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
        
        var outBuffer = vImage_Buffer(data: pixelBuffer, height: CGImageGetHeight(imageRef), width: CGImageGetWidth(imageRef), rowBytes: CGImageGetBytesPerRow(imageRef))
        
        var bColor : Array<UInt8> = [0,0,0,0]
        
        var error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, kernel, height, width, divisor, &bColor, UInt32(kvImageBackgroundColorFill))

        let out = UIImage(fromvImageOutBuffer: outBuffer, scale: image.scale, orientation: .Up)
        
        free(pixelBuffer)
        
        return out
    }
}

private extension UIImage {
    convenience init(fromvImageOutBuffer outBuffer:vImage_Buffer, scale:CGFloat, orientation: UIImageOrientation){
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var context = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGBitmapInfo(CGImageAlphaInfo.NoneSkipLast.toRaw()))
        
        var outCGimage = CGBitmapContextCreateImage(context)
        
        self.init(CGImage: outCGimage, scale:scale, orientation:orientation)
    }
}
