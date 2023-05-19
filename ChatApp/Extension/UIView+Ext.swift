//
//  UIView+Ext.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 19/5/23.
//

import Foundation
import UIKit

extension UIView {
    
    /// Adds the specified views as subviews to the current view.
    ///
    /// - Parameters:
    ///  - views: The views to be added as subviews.
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

