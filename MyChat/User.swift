//
//  User.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct User : Codable,Identifiable {
    @DocumentID var id : String?
    let uid,email,profileImage : String
    
    var userName : String{
        return email.replacingOccurrences(of: "@gmail.com", with: "")
    }
    
}
