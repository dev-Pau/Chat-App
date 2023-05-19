//
//  DataGateway.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 18/5/23.
//

import CoreData
import Foundation
import UIKit

/// A singleton gateway service used to interface with Core Data.
struct DataGateway {
    
    static let shared = DataGateway()
    let managedObjectContext: NSManagedObjectContext
    
    /// Creates an instance of the DataGateway with the managed object context from the AppDelegate.
    init() {
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

// MARK: - Create Operations

extension DataGateway {
    
    /// Saves a new Conversation to the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be saved.
    ///   - latestMessage: The first Message of the conversation.
    func save(conversation: Conversation, latestMessage: Message) {
        let messageEntity = latestMessage.getEntity(context: managedObjectContext)
        let conversationEntity = conversation.getEntity(context: managedObjectContext)
        messageEntity.conversation = conversationEntity
        conversationEntity.latestMessage = messageEntity
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Saves a new Message to the Core Data store.
    ///
    /// - Parameters:
    ///   - message: The Message to be saved.
    ///   - conversation: The parent Conversation.
    func save(message: Message, to conversation: Conversation) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId == %@", conversation.userId as CVarArg)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            
            if let conversationEntity = conversationEntities.first {
                let messageEntity = message.getEntity(context: managedObjectContext)
                messageEntity.conversation = conversationEntity
                conversationEntity.latestMessage = messageEntity
                print(messageEntity.kind)
                try managedObjectContext.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Retrieve Operations

extension DataGateway {
    
    /// Retrieves all Conversations from the Core Data store.
    ///
    /// - Returns:
    /// An array of saved Conversations.
    func getConversations() -> [Conversation] {
        var conversationEntities = [ConversationEntity]()
        
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        let pinnedSortDescriptor = NSSortDescriptor(key: "isPinned", ascending: false)
        let sentDateSortDescriptor = NSSortDescriptor(key: "latestMessage.sentDate", ascending: false)
        request.sortDescriptors = [pinnedSortDescriptor, sentDateSortDescriptor]
        
        do {
            conversationEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return conversationEntities.compactMap { Conversation(fromEntity: $0) }
    }
    
    /// Retrieves a batch of Messages from the Core Data store.
    /// - Parameters:
    ///   - conversation: The parent Conversation.
    ///
    /// - Returns:
    /// An array of saved Messages.
    func getMessages(for conversation: Conversation) -> [Message] {
        var messageEntities = [MessageEntity]()
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        request.fetchLimit = 40
        request.predicate = NSPredicate(format: "conversation.userId = %@", conversation.userId as CVarArg)
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }

        return messageEntities.compactMap { Message(fromEntitiy: $0) }.reversed()
    }
    
    /// Retrieves more Messages from the Core Data store.
    /// - Parameters:
    ///   - conversation: The parent Conversation.
    ///   - date: The Date starting point of the query.
    ///
    /// - Returns:
    /// An array of saved Messages.
    func getMoreMessages(for conversation: Conversation, from date: Date) -> [Message] {
        var messageEntities = [MessageEntity]()
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        request.fetchLimit = 40
        request.predicate = NSPredicate(format: "conversation.userId = %@ AND sentDate < %@", conversation.userId as CVarArg, date as NSDate)
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }

        return messageEntities.compactMap { Message(fromEntitiy: $0) }.reversed()
    }
}

// MARK: - Update Operations

extension DataGateway {
    
    /// Updates a given property for a given Conversation within the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be updated.
    ///   - value: The new value to be set.
    ///   - key: The key of the property to be updated.
    func edit(conversation: Conversation, set value: Any?, forKey key: String) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId = %@", conversation.userId as CVarArg)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            if let conversationEntity = conversationEntities.first {
                conversationEntity.setValue(value, forKey: key)
            }
            try managedObjectContext.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Updates all isRead messages properties for a given Conversation within the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be updated.
    func readMessages(conversation: Conversation) {
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "conversation.userId = %@ AND isRead = false", conversation.userId as CVarArg)
        
        do {
            let messages = try managedObjectContext.fetch(request)
            for message in messages {
                message.setValue(true, forKey: "isRead")
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Delete Operations

extension DataGateway {
    
    /// Deletes a given Conversation from the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be deleted.
    func delete(conversation: Conversation) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId = %@", conversation.userId as CVarArg)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            
            if let conversationEntity = conversationEntities.first {
                managedObjectContext.delete(conversationEntity)
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
