//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 13/5/23.
//

import UIKit

/// The view model for the Message.
class MessageViewModel {
    
    let message: Message
    
    /// Creates an instance of the MessageViewModel
    ///
    /// - Parameters:
    ///   - message: The message for the view model.
    ///
    /// - Returns:
    /// The rotated image,  or nil if the rotation fails.
    init(message: Message) {
        self.message = message
    }
    
    var isSender: Bool {
        return message.isSender
    }
    
    var text: String {
        return message.text
    }
    
    var date: String {
        return formatDateString(for: message.sentDate)
    }
    
    var image: UIImage? {
        guard let imagePath = message.image else { return nil }

        if let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let userImage = UIImage(data: data) {
            return userImage
        } else {
            print("Error loading image")
            return nil
        }
    }
    
    var imageUrl: URL? {
        guard let imagePath = message.image else { return nil }
        if let url = URL(string: imagePath) {
            return url
        } else {
            return nil
        }
    }
    
    func formatDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        let isToday = calendar.isDateInToday(date)
        let isYesterday = calendar.isDateInYesterday(date)
        let isWithinThisWeek = calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if isToday {
            formatter.dateFormat = "'Today' HH:mm"
            return formatter.string(from: date)
        } else if isYesterday {
            formatter.dateFormat = "'Yesterday' HH:mm"
            return formatter.string(from: date)
        } else if isWithinThisWeek {
            formatter.dateFormat = "EEEE HH:mm"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "EEEE, d MMM 'at' HH:mm"
            return formatter.string(from: date)
        }
    }
    
    
}
