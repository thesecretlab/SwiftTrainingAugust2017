//: [Previous](@previous)

import UIKit

func drawCircle(size: Int, color: UIColor) -> UIImage? {
    
    // Create a square CGSize
    let canvasSize = CGSize(width: size, height: size)
    
    // Create a new image context with this size
    UIGraphicsBeginImageContext(canvasSize)
    
    // Clean up after ourselves after we return
    defer {
        UIGraphicsEndImageContext()
    }
    
    // Define a rectangle that we'll draw our
    // circle in; start by creating a rect
    // of the same size as our canvas, and
    // then inset it
    let circleRect = CGRect(origin: CGPoint.zero, size: canvasSize)
        .insetBy(dx: 10, dy: 10)
    
    // Indicate to the context that we intend
    // to fill our shape with the provided
    // colour
    UIGraphicsGetCurrentContext()?
        .setFillColor(color.cgColor)
    
    // Create a circle path to draw
    let circle = UIBezierPath(ovalIn: circleRect)
    
    // Fill it
    circle.fill()
    
    // Return the final image
    return UIGraphicsGetImageFromCurrentImageContext()
    
}

// Draw some circles!
drawCircle(size: 200, color: .red)
drawCircle(size: 600, color: .brown)

//: [Next](@next)
