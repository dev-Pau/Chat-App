//
//  MessageEntity+CoreDataProperties.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 12/5/23.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var messageId: UUID?
    @NSManaged public var text: String?
    @NSManaged public var sentDate: Date?
    @NSManaged public var isSender: Bool
    @NSManaged public var image: String?
    @NSManaged public var kind: Int16
    @NSManaged public var isRead: Bool
    @NSManaged public var conversation: ConversationEntity?
}

extension MessageEntity : Identifiable {

}
