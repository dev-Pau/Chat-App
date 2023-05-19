//
//  Menu.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 18/5/23.
//

import Foundation
import UIKit

/// An enum mapping the photo menu prompts of a message.
enum MenuPhoto {
    case share
    
    var label: String {
        switch self {
        case .share: return "Share Photo"
        }
    }
    
    var image: UIImage {
        switch self {
        case .share: return UIImage(systemName: "square.and.arrow.up")!
        }
    }
}

/// An enum mapping the text menu prompts of a message.
enum MenuText {
    case copy
    
    var label: String {
        switch self {
        case .copy: return "Copy"
        }
    }
    
    var image: UIImage {
        switch self {
        case .copy: return UIImage(systemName: "doc")!
        }
    }
}
