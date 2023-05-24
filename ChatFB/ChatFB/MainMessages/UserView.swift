//
//  UserView.swift
//  ChatFB
//
//  Created by vvdn on 25/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserView: View {
    @ObservedObject private var viewModel = MainMessageViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipped()
                .cornerRadius(250)
                .overlay(RoundedRectangle(cornerRadius: 250)
                    .stroke(Color(.orange), lineWidth: 1)
                )
                .shadow(radius: 5)
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                let email = viewModel.chatUser?.userName
                Text(email ?? "")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                
            }

        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
