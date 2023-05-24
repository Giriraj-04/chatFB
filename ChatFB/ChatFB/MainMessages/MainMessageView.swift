//
//  MainMessageView.swift
//  ChatFB
//
//  Created by vvdn on 16/04/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift

struct MainMessageView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @State var shouldNavigateToChatLogView = false
    
    @State var shouldNavigateToProfileView = false
    
    @ObservedObject private var viewModel = MainMessageViewModel()
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    @State var userstatus = "offline"
    
    let timer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(viewModel: chatLogViewModel)
                }
                HStack{
                    newMessageButton
                        .padding(.bottom)
                        .frame(width: 200)
                        .frame(alignment: .bottomTrailing)
                    profileButton
                        .padding(.bottom)
                        .frame(width: 200)
                        .frame(alignment: .bottomTrailing)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.orange), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                let email = viewModel.chatUser?.userName
                Text(email ?? "")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text(FirebaseConstants.Online)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
//                shouldNavigateToProfileView.toggle()
//                NavigationView{
//                    NavigationLink("", isActive: $shouldNavigateToProfileView) {
//                        Profileview()
//                    }
//                }
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.orange))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    viewModel.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLogin: {
                self.viewModel.isUserCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
                self.viewModel.fetchRecentMessages()
                self.viewModel.updateOnlineUser()
            })
        }
//        .fullScreenCover(isPresented: $shouldNavigateToProfileView, onDismiss: nil) {
//            Profileview()
//        }
            
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(viewModel.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        self.chatUser = .init(data: [FirebaseConstants.email: recentMessage.email, FirebaseConstants.profileImageUrl: recentMessage.profileImageUrl, FirebaseConstants.uid: uid])
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color.orange, lineWidth: 1))
                                .shadow(radius: 5)
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.username)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                    .multilineTextAlignment(.leading)
                                if recentMessage.images == ""{
                                    Text(recentMessage.text)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(.darkGray))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                }else{
                                    Text("sent an attachment")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(.darkGray))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                }
                                
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
                            
                            if let match = viewModel.userstatus.first(where: { recentMessage.toId == $0.uid || recentMessage.fromId ==  $0.uid}){
                                
                                var status = match.isOnline
                                
                                if let online = status?[FirebaseConstants.isOnline], online == true{
                                    Circle()
                                        .foregroundColor(.green)
                                        .frame(width: 14, height: 14)
                                }else{
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 14, height: 14)
                                }
                            }else{
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }.onAppear {
            self.viewModel.updateOnlineUser()
        }
        .onReceive(timer) { _ in
            self.viewModel.updateOnlineUser()
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        HStack{
            Button {
                shouldShowNewMessageScreen.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.orange)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
            }
            .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                CreateNewMessageView(didSelectNewUser: { user in
                    print(user.email)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser = user
                    self.chatLogViewModel.chatUser = user
                    self.chatLogViewModel.fetchMessages()
                })
            }
        }
    }
    
    private var profileButton: some View {
        HStack{
            Button {
                shouldNavigateToProfileView.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("Profile")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.orange)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
            }
            .fullScreenCover(isPresented: $shouldNavigateToProfileView) {
                Profileview()
            }
        }
    }
    @State var chatUser: ChatUser?
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
            .preferredColorScheme(.dark)
        
        MainMessageView()
    }
}
