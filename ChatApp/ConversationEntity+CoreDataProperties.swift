//
//  ConversationEntity+CoreDataProperties.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 12/5/23.
//
//

import Foundation
import CoreData


extension ConversationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationEntity> {
        return NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var userId: UUID?
    @NSManaged public var messages: NSSet?
    @NSManaged public var isPinned: Bool
    @NSManaged public var latestMessage: MessageEntity?
    
    var wrappedLatestMessage: MessageEntity {
        latestMessage ?? MessageEntity()
    }
    
    var unreadMessages: Int {
        if let messagesSet = messages as? Set<MessageEntity> {
            let unreadMessages = messagesSet.filter { $0.isRead == false }
            return unreadMessages.count
        }
        return 0
    }
}

// MARK: Generated accessors for messages
extension ConversationEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension ConversationEntity : Identifiable {

}
