//
//  MainMessageViewModel.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

class MainMessageViewModel : ObservableObject{
    @Published var errorMessage = ""
    @Published var chatUser : User?
    @Published var recentMessages = [RecentMessage]()
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    init(){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func fetchCurrentUser(){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("cannot find current uid")
            self.errorMessage = "cannot find current uid"
            return
            
        }
        FirebaseManager.shared.fireStore.collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error{
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                }
                
               
                do{
                    self.chatUser = try snapshot?.data(as: User.self)
                    FirebaseManager.shared.currentUser = self.chatUser
                }catch{
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                }
                
                
                
            }
        
    }
    private var firebasestoreListener : ListenerRegistration?
    
     func fetchRecentMessages(){
        
        firebasestoreListener?.remove()
         recentMessages.removeAll()
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        
        
      firebasestoreListener =  FirebaseManager.shared.fireStore
             .collection(FirebaseConstants.recentMessage)
            .document(fromId)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timeStamp)
            .addSnapshotListener { snapShot, error in
                if let error = error{
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                    return
                }
                snapShot?.documentChanges.forEach({ change in
//                   if change.type == .added{
                       let documentId = change.document.documentID
                       if let index = self.recentMessages.firstIndex(where: { rm in
                           return rm.id == documentId
                       }) {
                           self.recentMessages.remove(at: index)
                       }
                       do {
                           let message = try change.document.data(as: RecentMessage.self)
                           self.recentMessages.insert(message, at: 0)
                           
                       } catch  {
                           debugPrint(error)
                           self.errorMessage = error.localizedDescription
                       }
                     
                    
//                    }
                   
                    
                })
            }
    }
}
