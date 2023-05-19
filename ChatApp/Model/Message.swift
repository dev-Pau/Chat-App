//
//  Message.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 13/5/23.
//

import CoreData
import Foundation

/// The model for a Message.
struct Message {
    
    let text: String
    let sentDate: Date
    let messageId: UUID
    private(set) var isRead: Bool
    let isSender: Bool
    let image: String?
    let kind: MessageKind
    
    /// Creates an instance of a Message.
    ///
    /// - Parameters:
    ///   - text: The raw, user-inputted title of the message.
    ///   - sentDate: The sent date of the message.
    ///   - messageId: The unique identifier for the instance. By default, this is set to a generated UUID.
    ///   - isRead: The value of the isRead for this conversation.
    ///   - isSender: The value of the isSender for this conversation.
    ///   - image: The raw directory string directory of the image.
    ///   - kind: The associated kind of the message.
    init(text: String, sentDate: Date, messageId: UUID, isRead: Bool, isSender: Bool, image: String? = nil, kind: MessageKind) {
        self.text = text
        self.sentDate = sentDate
        self.messageId = messageId
        self.isRead = isRead
        self.isSender = isSender
        self.image = image
        self.kind = kind
    }
    
    /// Creates an instance of Message from a Core Data entity.
    ///
    /// - Parameters:
    ///   - entity: The MessageEntity instance from the Core Data store.
    init?(fromEntitiy entity: MessageEntity) {
        self.text = entity.text ?? ""
        self.sentDate = entity.sentDate ?? Date()
        self.messageId = entity.messageId ?? UUID()
        self.isRead = entity.isRead
        self.isSender = entity.isSender
        self.image = entity.image ?? nil
        self.kind = MessageKind(rawValue: entity.kind)!
    }
    
    /// Creates a MessageEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of MessageEntity.
    @discardableResult
    func getEntity(context: NSManagedObjectContext) -> MessageEntity {
        let entity = MessageEntity(context: context)
        
        entity.text = text
        entity.sentDate = sentDate
        entity.messageId = messageId
        entity.isRead = isRead
        entity.isSender = isSender
        entity.image = image
        entity.kind = kind.rawValue

        return entity
    }
    
    /// Updates the instance's isRead property.
    mutating func markAsRead() {
        isRead = true
    }
}
