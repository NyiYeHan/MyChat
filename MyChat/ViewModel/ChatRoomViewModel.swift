//
//  ChatRoomViewModel.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift


class ChatRoomViewModel : ObservableObject{
    @Published var errorMessage = ""
    @Published var user : User? = nil
    @Published var chatText = ""
    @Published var messages = [ChatMessage]()
    
    @Published var count = 0
    
    init(user : User?){
        self.user = user
        fetchMessage()
    }
     func fetchMessage(){
         
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = user?.uid else{return}
        
         self.messages.removeAll()
        FirebaseManager.shared.fireStore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timeStamp)
            .addSnapshotListener { snapShot, error in
                if let error = error{
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                    return
                }
                snapShot?.documentChanges.forEach({ change in
                    if change.type == .added{
                        
                        
                        do {
                            let message = try change.document.data(as: ChatMessage.self)
                            self.messages.append(message)
                        } catch  {
                            debugPrint(error)
                            self.errorMessage = error.localizedDescription
                        }
                        
//                        self.messages.append(.init(documentId: documentId, data: data))
                       
                    }
                })
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    
    func presistRecentMessage(){
        guard let user = user else { return }
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        let toId = user.uid
        let document = FirebaseManager.shared.fireStore.collection(FirebaseConstants.recentMessage)
            .document(fromId)
            .collection(FirebaseConstants.messages)
            .document(toId)
        let messageData =  [FirebaseConstants.fromId : fromId ,
                            FirebaseConstants.toId : toId ,
                            FirebaseConstants.text : self.chatText ,
                            FirebaseConstants.timeStamp : Date(),
                            FirebaseConstants.email : user.email,
                            FirebaseConstants.profileImage : user.profileImage] as [String: Any]
        
        document.setData(messageData){ error in
            if let error = error{
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                return
            }
        }
        
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timeStamp: Date(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImage: currentUser.profileImage,
            FirebaseConstants.email: currentUser.email
        ] as [String : Any]
        
        FirebaseManager.shared.fireStore
            .collection(FirebaseConstants.recentMessage)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    func sendMessage(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = user?.uid else{return}
        
        let document = FirebaseManager.shared.fireStore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timeStamp: Date())
        
        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.presistRecentMessage()
            self.chatText = ""
            self.count += 1
           
        }
        
        let recipientMessageDocument = FirebaseManager.shared.fireStore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Recipient saved message as well")
           
        }
        
    }
}
