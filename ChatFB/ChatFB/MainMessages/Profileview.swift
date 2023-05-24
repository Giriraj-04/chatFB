//
//  Profileview.swift
//  ChatFB
//
//  Created by vvdn on 27/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct Profileview: View {
    @ObservedObject private var viewModel = MainMessageViewModel()
    @State var shouldShowLogOutOptions = false
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        NavigationView{
            VStack(spacing: 16) {
                WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250)
                    .clipped()
                    .cornerRadius(250)
                    .overlay(RoundedRectangle(cornerRadius: 240)
                        .stroke(Color(.orange), lineWidth: 1)
                    )
                    .shadow(radius: 5)
                Spacer()
                ZStack(alignment: .leading){
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(){
                            Text("User Name:")
                                .font(.system(size: 24, weight: .bold))
                            let username = viewModel.chatUser?.userName
                            Spacer()
                            Text(username ?? "")
                                .font(.system(size: 24, weight: .bold))
                        }
                        Spacer(minLength: 10)
                        HStack(){
                            Text("email id:")
                                .font(.system(size: 24, weight: .bold))
                            Spacer()
                            let email = viewModel.chatUser?.email
                            Text(email ?? "")
                                .font(.system(size: 24, weight: .bold))
                        }
                        Spacer(minLength: 10)
                        HStack(){
                            Text("Phone Number:")
                                .font(.system(size: 24, weight: .bold))
                            Spacer()
                            let phno = viewModel.chatUser?.phno
                            Text(phno ?? "")
                                .font(.system(size: 24, weight: .bold))
                        }
                        Spacer(minLength: 10)
                        
                        
                    }
                    Spacer()
                }
                Spacer()
                
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.original)
                            .font(.title)
                        Text("Back")
                    }
                }
            }
        }
    }
}

struct Profileview_Previews: PreviewProvider {
    static var previews: some View {
        Profileview()
    }
}
