//
//  MainMessageView.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainMessageView: View {
    
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessageViewModel()
    @State var showNewMessageView = false
    @State var showChatRoom = false
    @State var user : User? = nil
    private var chatRoomViewModel = ChatRoomViewModel(user: nil)
    
    
    var body: some View {
        
        NavigationView {
            VStack{
                customNavBar
                messagesView
                NavigationLink("", isActive: $showChatRoom) {
                    ChatRoom(vm: chatRoomViewModel)
                }
                
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            
        }
        
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { message in
                Button {
                    let uid = FirebaseManager.shared.auth.currentUser?.uid == message.fromId ? message.toId : message.fromId
                    
                    self.user = .init(id: uid, uid: uid, email: message.email, profileImage: message.profileImage)
                    
                    self.chatRoomViewModel.user = self.user
                    self.chatRoomViewModel.fetchMessage()
                    self.showChatRoom.toggle()
                    
                } label: {
                    VStack {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: message.profileImage))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                            
                            
                            VStack(alignment: .leading) {
                                Text(message.userName)
                                    .font(.system(size: 16, weight: .bold))
                                Text(message.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text(message.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }.padding(.horizontal)
                        .foregroundColor(.black)
                }

               
                
            }.padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View {
        Button {
            self.showNewMessageView.toggle()
        } label: {
            
            Text("+ New Message")
                .font(.system(size: 16, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .padding(.vertical)
        .background(Color.blue)
        .cornerRadius(32)
        .padding(.horizontal)
        .shadow(radius: 15)
        .fullScreenCover(isPresented: $showNewMessageView) {
            CreateNewMessageView { user in
                self.chatRoomViewModel.user = user
                self.chatRoomViewModel.fetchMessage()
                self.showChatRoom = true
            }
        }
    }
    
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.chatUser?.profileImage ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.chatUser?.userName ?? "UserName")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
            LoginView {
                vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
            }
        }
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
    }
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
