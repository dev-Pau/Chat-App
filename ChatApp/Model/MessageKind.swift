//
//  MessageKind.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 15/5/23.
//

import UIKit

/// An enum mapping the types of messages that can be send within the app.
enum MessageKind: Int16, CaseIterable {
    
    case text, photo
}
