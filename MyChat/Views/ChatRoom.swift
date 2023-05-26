//
//  ChatRoom.swift
//  MyChat
//
//  Created by Nyi Ye Han on 24/05/2023.
//

import SwiftUI

struct ChatRoom: View {
    
    @ObservedObject var vm : ChatRoomViewModel
    
//    init(user : User? = nil){
//        self.user = user
//        self.vm = .init(user: user)
//    }
    var body: some View {
        ZStack {
            messagesView
            
           
        }
        .navigationTitle(vm.user?.userName ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
     fileprivate func MessageView(_ message: ChatMessage) -> some View {
        return HStack {
            if !message.isIncomingMessage{
                Spacer()
            }
            
            HStack {
                Text(message.text)
                    .foregroundColor(message.isIncomingMessage ? .black : .white)
            }
            .padding()
            .background(message.isIncomingMessage ? .white : .blue)
            .cornerRadius(8)
            if message.isIncomingMessage{
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    var messagesView: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack{
                    ForEach(vm.messages) { message in
                        
                        MessageView(message)
                    }
                    
                    HStack{ Spacer() }
                        .id(FirebaseConstants.scrollId)
                    
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeInOut(duration: 0.5)){
                        proxy.scrollTo(FirebaseConstants.scrollId)
                    }
                }
            }
           
            
            
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
        
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                vm.sendMessage()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
}

struct ChatRoom_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoom(vm: ChatRoomViewModel(user: nil))
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
