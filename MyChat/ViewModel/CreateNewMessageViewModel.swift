//
//  CreateNewMessageViewModel.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import Foundation

class CreateNewMessageViewModel : ObservableObject{
    
    @Published var errorMessage  = ""
    @Published var users  = [User]()
    init(){
        fetchAllUser()
    }
    
    func fetchAllUser(){
        FirebaseManager.shared.fireStore.collection("users")
            .getDocuments { snapShot, error in
                if let error = error{
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                }
                snapShot?.documents.forEach({ document in
                    do {
                        let user = try document.data(as: User.self)
                        if user.uid != FirebaseManager.shared.auth.currentUser?.uid{
                            self.users.append(user)
                        }
                    } catch  {
                        self.errorMessage = error.localizedDescription
                        print(error.localizedDescription)
                    }
                    
                   
                    
                })
            }
    }
}
