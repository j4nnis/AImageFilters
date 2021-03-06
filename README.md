# AImageFilters

Functional Swift wrapper around a few matrix convolution functions from the Accelerate Framework ([vImage Convolution Reference](https://developer.apple.com/library/ios/documentation/Performance/Reference/vImage_convolution/index.html#//apple_ref/doc/uid/TP40005489)). Inspired by objc.io issue 16 [(Functional APIs with Swift)](http://www.objc.io/issue-16/functional-swift-apis.html). I wrote this mainly because I did some research on image processing and because the functional nature of the API now possible with Swift and suggested in the objc.io issue fascinated me. This code is not optimized because its main purpose was to teach me how to use Accelerate from Swift.

## Filters

The filters are mostly just different convolution matrices. I used this wikipedia article as a source for example matrices: [Kernel (image processing)](http://en.wikipedia.org/wiki/Kernel_(image_processing)).

vImageConvolve does the heavy lifting.

* Sharpen
* Gaussian blur
* 3 different edge detection matrices
* 5x5 Unsharp
* Box blur (using the dedicated function vImageBoxConvolve)

These are only examples of kernels.

## Usage

```swift

var boxFilter = boxBlur(3)
var gaussFilter = gaussBlur()

var bothFilers = boxFilter >|> gaussFilter
var output = bothFilters(UIImage(named:"test"))

var sharpenTwice = sharpen() * 2
var sharper = sharpenTwice(UIImage(named:"test"))

```
