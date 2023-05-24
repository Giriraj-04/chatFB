//
//  ChatLogView.swift
//  ChatFB
//
//  Created by vvdn on 16/04/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ChatLogView: View {
    @State private var shouldShowImagePicker = false
    @State private var shouldShowActionSheet = false
    @State private var shouldShowCameraImagePicker = false

    
    @ObservedObject var viewModel: ChatLogViewModel
    var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @State var image: UIImage?
    var body: some View {
        ZStack {
            messagesView
        }
        .navigationTitle((viewModel.chatUser?.email.components(separatedBy: "@").first ?? viewModel.chatUser?.email) ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.firestoreListener?.remove()
        }
        .onAppear {
            self.viewModel.fetchMessages()
        }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        VStack {
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(viewModel.chatMessages) { message in
                                MessageView(message: message)
                            }
                            
                            HStack{ Spacer() }
                                .id(Self.emptyScrollToString)
                            
                        }
                        .onReceive(viewModel.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            }
                        }
                    }
                    if viewModel.isloading == true{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                }
                .background(Color(.systemBackground))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            }
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Button{
                shouldShowActionSheet.toggle()
                
            }label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.orange))
            }
            
            ZStack {
                Spacer()
                DescriptionPlaceholder()
                TextEditor(text: $viewModel.chatText)
                    .opacity(viewModel.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                if viewModel.chatText.isEmpty && viewModel.image == nil{
                }else{
                    viewModel.handleSend()
                }
            } label: {
                if viewModel.isloading == true {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }else {
                    Text("Send")
                        .foregroundColor(.white)
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.orange)
            .cornerRadius(4)
            
            
            
        }
        .fullScreenCover(isPresented: $shouldShowCameraImagePicker, onDismiss: viewModel.handleSend) {
            ImagePicker(image: $viewModel.image,sourceType: .camera)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: viewModel.handleSend) {
            ImagePicker(image: $viewModel.image,sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .actionSheet(isPresented: $shouldShowActionSheet) {
            .init(title: Text("Action"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Camera"), action: {
                    print("Camera")
                    shouldShowCameraImagePicker.toggle()
                }),
                .destructive(Text("Photo gallery"), action: {
                    print("Photo gallery")
                    shouldShowImagePicker.toggle()
                }),
                .cancel()
            ])
        }
//        .sheet(isPresented: $shouldShowImagePicker,onDismiss: nil){
//            ImageSelectionSheet(viewModel: chatLogViewModel)
//                .presentationDetents([.fraction(0.1)])
//        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}


struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        if message.images != "" {
                            ZStack(alignment: .bottomTrailing){
                                WebImage(url: URL(string: message.images ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipped()
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.orange), lineWidth: 1)
                                    )
                                    .shadow(radius: 5)
                                VStack{
                                    if message.seen {
                                        Image(systemName: "checkmark.circle.fill")
                                    } else {
                                        Image(systemName: "checkmark.circle")
                                    }
                                }.padding()
                            }
                        }else{
                            HStack{
                                Text(message.text)
                                    .foregroundColor(.white)
                                if message.seen {
                                    Image(systemName: "checkmark.circle.fill")
                                } else {
                                    Image(systemName: "checkmark.circle")
                                }
                            }.padding()
                                .background(Color.orange)
                                .cornerRadius(8)
                            
                        }
                        
                    }
                    
                }
            } else {
                HStack {
                    HStack {
                        if message.images != "" {
                            WebImage(url: URL(string: message.images ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 250)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.label), lineWidth: 1)
                                )
                            
                                .shadow(radius: 5)
                        }else{
                            HStack{
                                Text(message.text)
                                    .foregroundColor(.black)
                            }.padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.label), lineWidth: 1))
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
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

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        //        NavigationView {
        //            ChatLogView(chatUser: .init(data: ["uid": "R8ZrxIT4uRZMVZeWwWeQWPI5zUE3", "email": "waterfall1@gmail.com"]))
        //        }
        MainMessageView()
            .preferredColorScheme(.dark)
        MainMessageView()
    }
}
