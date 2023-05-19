//
//  Chat.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 12/5/23.
//

import CoreData
import Foundation

/// The model for a Conversation.
struct Conversation: Equatable {
    
    let name: String
    let image: String?
    let userId: UUID
    private(set) var unreadMessages: Int
    private(set) var isPinned: Bool
    private(set) var latestMessage: Message
    
    /// Creates an instance of a Conversation.
    ///
    /// - Parameters:
    ///   - name: The name of the user of this conversation.
    ///   - image: The image of the user of this conversation.
    ///   - userId: The unique identifier for the instance. By default, this is set to a generated UUID.
    ///   - unreadMessages: The number of unread messages of this conversation.
    ///   - isPinned: The value of the isPinned for this conversation.
    ///   - latestMessage: The latest Message associated with this conversation.
    init(name: String, image: String?, userId: UUID, unreadMessages: Int, isPinned: Bool, latestMessage: Message) {
        self.name = name
        self.image = image
        self.userId = userId
        self.unreadMessages = unreadMessages
        self.isPinned = isPinned
        self.latestMessage = latestMessage
    }
    
    /// Creates an instance of Conversation from a Core Data entity.
    ///
    /// - Parameters:
    ///   - entity: The ConversationEntity instance from the Core Data store.
    init?(fromEntity entity: ConversationEntity) {
        self.name = entity.name ?? "Unknown"
        self.userId = entity.userId ?? UUID()
        self.image = entity.image ?? "xmark"
        self.unreadMessages = entity.unreadMessages
        self.isPinned = entity.isPinned
        self.latestMessage = Message(fromEntitiy: entity.wrappedLatestMessage)!
    }
    
    /// Creates a ConversationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of ConversationEntity.
    @discardableResult
    func getEntity(context: NSManagedObjectContext) -> ConversationEntity {
        let entity = ConversationEntity(context: context)
        
        entity.name = name
        entity.image = image
        entity.userId = userId
        entity.isPinned = isPinned
        
        return entity
    }
    
    /// Updates the instance's unreadMessages property.
    mutating func markMessagesAsRead() {
        unreadMessages = 0
        latestMessage.markAsRead()
    }
    
    /// Updates the instance's latestMessage property.
    ///
    /// - Parameters:
    ///   - newLatestMessage: The new latestMessage to be updated.
    mutating func changeLatestMessage(to newLatestMessage: Message) {
        latestMessage = newLatestMessage
    }
    
    /// Updates the instance's isPinned property.
    mutating func togglePin() {
        isPinned.toggle()
    }
}

// MARK: - Comparable Conformity For Sorting

extension Conversation {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.userId == rhs.userId
    }
}

