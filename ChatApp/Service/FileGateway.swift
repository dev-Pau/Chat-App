//
//  FileGateway.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 18/5/23.
//

import Foundation
import UIKit

/// A singleton file gateway service used to interface with the documents directory.
struct FileGateway {
    
    static let shared = FileGateway()
    
    /// Saves an image to the document directory.
    ///
    /// - Parameters:
    ///   - image: The image to be saved.
    ///   - userId: The userID associated with the image.
    ///
    ///  - Returns:
    ///  The URL of the saved image, or nil if saving failed.
    func saveImage(_ image: UIImage, userId: UUID) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        guard let libraryDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let imageFileName = "\(userId).jpg"
        let imageUrl = libraryDirectory.appendingPathExtension(imageFileName)
        
        do {
            try imageData.write(to: imageUrl)
            return imageUrl
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
