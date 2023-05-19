//
//  AppStrings.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 19/5/23.
//

import Foundation

/// A structure containing static strings used throughout the app.
struct AppStrings {
    
    struct Global {
        static let done = "Done"
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let add = "Add"
        static let receive = "Receive"
    }
    
    struct ConversationAlert {
        static let delete = "Delete Conversation"
        static let deleteAlert = "This conversation will be deleted from your inbox. Other pople in the conversation will still be able to see it."
    }
    
    struct Icons {
        static let pin = "pin"
        static let fillPin = "pin.fill"
        static let trash = "trash"
        static let copy = "doc"
        static let share = "square.and.arrow.up"
    }
    
    struct Actions {
        static let pin = "Pin"
        static let unpin = "Unpin"
        static let copy = "Copy"
        static let share = "Share"
    }
    
    struct Title {
        static let conversation = "Conversations"
        static let message = "Messages"
        static let user = "Add User"
    }
    
    struct Welcome {
        static let title = "Welcome to your inbox."
        static let subtitle = "Drop a line, share photos and more with private conversations between you and others."
    }
}
