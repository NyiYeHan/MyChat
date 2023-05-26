//
//  ContentView.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import SwiftUI
import Firebase

import FirebaseStorage
import FirebaseFirestore






struct LoginView: View {
    
    @State var loginMode = false
    @State var email = ""
    @State var password = ""
    @State var loginStatus = ""
    @State var shouldShowImagePicker = false
    @State var image : UIImage?
    var complete : () -> Void
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(spacing: 16){
                    Picker("title", selection: $loginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(.segmented)
                    
                    if !loginMode{
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack{
                                if let image = image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128,height: 128)
                                        .cornerRadius(64)
                                }else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            
                           
                        }
                    }
                   
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            
                        
                        SecureField("password" ,text: $password)
                    }
                    .padding(12)
                    .background(.white)
                    
                    
                    
                    Button {
                        handleAction()
                    } label: {
                        Text(loginMode ? "Login" :"Create Account")

                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical ,10)
                    .foregroundColor(.white)
                    .background(.blue)
                    
                    Text(loginStatus)
                    
                   
                    
                    
                    
                }
                .padding()
                
                .navigationTitle(loginMode ?"Login" : "Create Account")
            }
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
            .fullScreenCover(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
            }
        }
        
        
    }
    
    fileprivate func persistImageToStorage(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else{
            self.loginStatus = "Please select image"
            return
            
        }
        
        ref.putData(imageData,metadata: nil) { metadata, error in
            if let error = error{
                print(error.localizedDescription)
                loginStatus = error.localizedDescription
            }
            ref.downloadURL { url, error in
                if let error = error{
                    loginStatus = error.localizedDescription
                }
                guard let url = url else{return}
                storeInformation(url: url.absoluteString)
            }
        }
        
    }
    
    fileprivate func CreateUser() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){result,error in
            if let error = error{
                print(error.localizedDescription)
                self.loginStatus = error.localizedDescription
                return
            }
            
            print("successfully create user : \(result?.user.uid ?? "unknown user id ")")
            persistImageToStorage()
        }
    }
    
    fileprivate func Login() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){ result,error in
            if let error = error{
                print(error.localizedDescription)
                self.loginStatus = error.localizedDescription
                return
            }
            
            print("successfully login user : \(result?.user.uid ?? "unknown user id ")")
            complete()
        }
    }
    
    fileprivate func handleAction(){
        if loginMode{
            Login()
        }else{
            CreateUser()
        }
    }
    fileprivate func storeInformation(url : String){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        let userData = ["email" : email , "uid" : uid , "profileImage" : url]
        FirebaseManager.shared.fireStore.collection("users")
            .document(uid).setData(userData){error in
                if let error = error{
                    print(error.localizedDescription)
                    self.loginStatus = error.localizedDescription
                }
                complete()
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView( complete: {})
    }
}



