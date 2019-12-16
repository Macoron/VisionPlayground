import UIKit
import PlaygroundSupport

import Foundation
import CoreML
import Vision

func drawPolygon(image: UIImage, barcode : VNBarcodeObservation) -> UIImage {
    let imageSize = image.size
    let scale: CGFloat = 0
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
    image.draw(at: CGPoint.zero)
    UIColor.red.setStroke()
    
    let keyPoints = [barcode.bottomLeft, barcode.topLeft, barcode.topRight, barcode.bottomRight]
    
    let scaledPoints = keyPoints.map { (point) -> CGPoint in
        return CGPoint(x: point.x * imageSize.width, y: (1 - point.y) * imageSize.height)
    }
    
    let path = UIBezierPath()
    path.move(to: scaledPoints[0])
    for point in scaledPoints[1...] {
        path.addLine(to: point)
    }
    path.addLine(to: scaledPoints.first!)
    path.close()
    path.stroke()

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func detectQR(imageName : String) -> UIImage
{
    let image = UIImage(named: imageName)!
    let cgImage = image.cgImage!

    // Create a request handler.
    let handler = VNImageRequestHandler(cgImage: cgImage)
    
    let barcodeDetectRequest = VNDetectBarcodesRequest()
    barcodeDetectRequest.symbologies = [.QR]
    
    try! handler.perform([barcodeDetectRequest])
    
    let barcodeObservations = barcodeDetectRequest.results as? [VNBarcodeObservation]
    
    var newImg = image
    for barcode in barcodeObservations! {
        newImg = drawPolygon(image: newImg, barcode: barcode)
    }
    
    return newImg
}

/*func handleDetectedBarcodes(request: VNRequest?, error: Error?) {
if let nsError = error as NSError? {
    self.presentAlert("Barcode Detection Error", error: nsError)
    return
}*/

//let detectedQR = detectQR("frame.jpg")
let img = detectQR(imageName: "qr-code-in-building.jpg")
