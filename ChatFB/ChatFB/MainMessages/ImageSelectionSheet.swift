//
//  ImageSelectionSheet.swift
//  ChatFB
//
//  Created by vvdn on 01/05/23.
//

import SwiftUI

struct ImageSelectionSheet: View {
    @State private var shouldShowImagePicker = false
    @State private var shouldShowCameraImagePicker = false
    @State var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: ChatLogViewModel
    var body: some View {
        HStack{
            Spacer()
            Button{
                shouldShowCameraImagePicker.toggle()
                self.presentationMode.wrappedValue.dismiss()
            }label: {
                Image(uiImage: UIImage(named: "camera")!)
                    .font(.system(size: 40))
                    .padding()
                    .foregroundColor(Color(.label))
                    .frame(width: 150,height: 150)
            }
            Spacer()
            Button{
                shouldShowImagePicker.toggle()
                self.presentationMode.wrappedValue.dismiss()
            }label: {
                Image(uiImage: UIImage(named: "gallery")!)
                    .font(.system(size: 100))
                    .padding()
                    .foregroundColor(Color(.label))
                    .frame(width: 150,height: 150)
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $shouldShowCameraImagePicker, onDismiss: viewModel.handleSend) {
            ImagePicker(image: $viewModel.image,sourceType: .camera)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: viewModel.handleSend) {
            ImagePicker(image: $viewModel.image,sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
    }
}

struct ImageSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
//        ImageSelectionSheet(viewModel: <#ChatLogViewModel#>)
        MainMessageView()
    }
}
