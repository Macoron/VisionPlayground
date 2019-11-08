//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

import Foundation
import CoreML
import Vision


func drawRectangleOnImage(image: UIImage, rectangles : [CGRect]) -> UIImage {
    let imageSize = image.size
    let scale: CGFloat = 0
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

    image.draw(at: CGPoint.zero)

    UIColor.red.setStroke()
    for normRect in rectangles {
        let rectangle = CGRect(x: normRect.origin.x * imageSize.width,
                               y: (1 - normRect.origin.y - normRect.height) * imageSize.height,
                               width: normRect.width * imageSize.width,
                               height: normRect.height * imageSize.height)

        UIRectFrame(rectangle)
    }


    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func drawFaceLandmarks(image: UIImage, faceDetection : VNFaceLandmarks2D) -> UIImage  {
    let imageSize = image.size
    let scale: CGFloat = 0
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

    image.draw(at: CGPoint.zero)
    
    let allPoints = faceDetection.allPoints?.pointsInImage(imageSize: imageSize)
    
    UIColor.green.setFill()
    for point in allPoints! {

        let rect = CGRect.init(x: point.x, y: imageSize.height - point.y, width: 1, height: 1)
        UIRectFill(rect)
    }

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func faceDetector(imageName : String) -> UIImage
{
    let image = UIImage(named: imageName)!
    let cgImage = image.cgImage!

    // Create a request handler.
    let handler = VNImageRequestHandler(cgImage: cgImage)

    let rectDetectRequest = VNDetectFaceLandmarksRequest.init()

    try! handler.perform([rectDetectRequest])
    let faceObservations = rectDetectRequest.results as? [VNFaceObservation]

    var rects = [CGRect]()
    var landmarks = [VNFaceLandmarks2D]()
    
    for observation in faceObservations! {
        let rect = observation.boundingBox
        rects.append(rect)
        
        if (observation.landmarks != nil) {
            landmarks.append(observation.landmarks!)
        }
    }

    var newImg = drawRectangleOnImage(image: image,  rectangles : rects)
    
    for landmark in landmarks {
        newImg = drawFaceLandmarks(image: newImg, faceDetection: landmark)
    }
    
    return newImg
}

let lena = faceDetector(imageName: "lena.jpeg")
let morePeople = faceDetector(imageName: "more_people.jpg")

