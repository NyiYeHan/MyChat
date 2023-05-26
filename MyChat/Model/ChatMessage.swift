//
//  ChatMessage.swift
//  MyChat
//
//  Created by Nyi Ye Han on 25/05/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timeStamp = "timeStamp"
    static let scrollId = "empty"
    static let email = "email"
    static let profileImage = "profileImage"
    static let uid = "uid"
    static let recentMessage = "recent_messages"
    static let messages = "messages"
    
    
}

struct ChatMessage : Codable,Identifiable {
    @DocumentID var id : String?
    
    let fromId, toId, text : String
    let timeStamp : Date
    var isIncomingMessage : Bool{
        return fromId != FirebaseManager.shared.auth.currentUser?.uid
    }
}
