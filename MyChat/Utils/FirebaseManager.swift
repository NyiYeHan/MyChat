//
//  FirebaseManager.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import Foundation
import Firebase

import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let fireStore : Firestore
    var currentUser : User?
    
    static let shared = FirebaseManager()
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
        super.init()
    }
    
}
