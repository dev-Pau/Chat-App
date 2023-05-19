//
//  ConversationViewModel.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 13/5/23.
//

import UIKit

/// The view model for the Conversation.
class ConversationViewModel {
    
    private let conversation: Conversation
    
    /// Creates an instance of the ConversationViewModel.
    ///
    /// - Parameters:
    ///   - conversation: The conversation of the view model.
    init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    var name: String {
        return conversation.name
    }
    
    var image: UIImage? {
        guard let imagePath = conversation.image else { return UIImage(named: "user.profile") }

        if let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let userImage = UIImage(data: data) {
            return userImage
        } else {
            return UIImage(named: "user.profile")
        }
    }
    
    private var isSender: Bool {
        return conversation.latestMessage.isSender
    }
    
    var lastMessage: String {
        let text = conversation.latestMessage.text
        return isSender ? "You: " + text : text
    }
    
    var lastMessageDate: String {
        let sentDate = conversation.latestMessage.sentDate
        
        let date = sentDate.formatted(date: .omitted, time: .shortened)
        return date
    }
    
    var unreadMessages: Int {
        return conversation.unreadMessages
    }
    
    var isPinned: Bool {
        return conversation.isPinned
    }

    var messageColor: UIColor {
        return conversation.latestMessage.isRead ? .secondaryLabel : .systemBlue
    }
    
    var pinImage: UIImage {
        return (UIImage(systemName: AppStrings.Icons.fillPin)!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).rotate(radians: .pi/4))!
    }
}
