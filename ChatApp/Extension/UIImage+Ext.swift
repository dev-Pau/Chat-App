//
//  UIImage+Ext.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 19/5/23.
//

import Foundation
import UIKit

extension UIImage {
    
    /// Rotates the image by the specified angle in radians.
    ///
    /// - Parameters:
    ///   - radians: The angle in radians by which to rotate the image.
    ///
    /// - Returns:
    /// The image rotated or nil if there's some error.
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
