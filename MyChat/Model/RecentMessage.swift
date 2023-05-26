//
//  RecentMessage.swift
//  MyChat
//
//  Created by Nyi Ye Han on 25/05/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage : Codable,Identifiable{
    @DocumentID var id : String?
    var userName: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timeStamp, relativeTo: Date())
    }
    
    let fromId ,toId, text,email ,profileImage : String
    let timeStamp : Date
}
