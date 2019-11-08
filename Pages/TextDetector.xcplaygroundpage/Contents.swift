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

func recognizeText(imageName : String, recognitionLevel : VNRequestTextRecognitionLevel, maxCandidates : Int)
    -> UIImage
{
    let image = UIImage(named: imageName)!
    let cgImage = image.cgImage!

    // Create a request handler.
    let handler = VNImageRequestHandler(cgImage: cgImage)

    let detectText = VNRecognizeTextRequest()
    detectText.recognitionLevel = recognitionLevel

    try! handler.perform([detectText])
    let textObservation = detectText.results as? [VNRecognizedTextObservation]

    var rects = [CGRect]()
    for observation in textObservation! {
        rects.append(observation.boundingBox)
        let candidates = observation.topCandidates(maxCandidates)
        for textCandidate in candidates {
            print("\(textCandidate.confidence): \(textCandidate.string)")
        }
    }

    let resultImage = drawRectangleOnImage(image: image, rectangles: rects)
    return resultImage
}

let img = recognizeText(imageName: "text.jpeg", recognitionLevel: .accurate, maxCandidates: 3)


