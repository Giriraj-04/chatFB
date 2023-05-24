//
//  CreateNewMessageView.swift
//  ChatFB
//
//  Created by vvdn on 16/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(.orange), lineWidth: 2)
                                )
                            Text(user.userName)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView(didSelectNewUser: { user in
            print(user.email)
        })
        .preferredColorScheme(.dark)
        CreateNewMessageView(didSelectNewUser: { user in
            print(user.email)
        })
    }
}
