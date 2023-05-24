//
//  ContentView.swift
//  ChatFB
//
//  Created by vvdn on 15/04/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    let didCompleteLogin: () -> ()
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var userName = ""
    @State private var phno = ""
    @State private var birthDate = Date.now
    @State private var shouldShowImagePicker = false
    @State private var showError = false
    @State private var shouldShowCameraImagePicker = false
    @State private var shouldShowActionSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            shouldShowActionSheet.toggle()
                            
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.primary, lineWidth: 3)
                            )
                            
                        }
                        Group {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                            TextField("User Name", text: $userName)
                            DatePicker(selection: $birthDate, in: ...Date.now, displayedComponents: .date) {
                                Text("Date of Birth")
                                    .foregroundColor(Color.black)
                            }
                            .foregroundColor(.blue)
                            TextField("Phone Number", text: $phno)
                                .keyboardType(.numberPad)
                        }
                        .padding(12)
                        .background(Color(.gray))
                        
                        
                        
                    }else{
                        Group {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                        }
                        .padding(12)
                        .background(Color.gray)
                        
                    }
                    Button {
                        if let errorMessage = self.validView() {
                            print(errorMessage)
                            loginStatusMessage = errorMessage
                            showError = true
                            return
                        }else{
                            handleAction()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                        
                    }
                    .alert(isPresented: $showError) {
                        Alert(title: Text("Error"), message: Text(loginStatusMessage), dismissButton: .default(Text("OK")))
                    }
                    .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        .fullScreenCover(isPresented: $shouldShowCameraImagePicker, onDismiss: nil) {
            ImagePicker(image: $image,sourceType: .camera)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image,sourceType: .photoLibrary)
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
//        .sheet(isPresented: $shouldShowImagePicker){
//            ImageSelectionSheet(image: image)
//                .presentationDetents([.fraction(0.1)])
//        }
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err.localizedDescription)"
                return
                showError = true
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLogin()
            if FirebaseManager.shared.auth.currentUser != nil {
                OnlineOfflineService.online(for: (Auth.auth().currentUser?.uid)!, status:true){ (success) in
                    
                    print("User ==>", success)
                    
                    FirebaseManager.shared.database.reference().observeSingleEvent(of: .value, with: { snapshot in
                        for child in snapshot.children {
                            if let snap = child as? DataSnapshot,
                               let value = snap.value as? [String: Any] {
                                // handle value here
                                print(value)
                            }
                        }
                    })
                }
            }
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        if self.image == nil{
            self.loginStatusMessage = "Please select an image for profile"
            showError = true
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err.localizedDescription)"
                showError = true
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err.localizedDescription)"
                showError = true
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err.localizedDescription)"
                    showError = true
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString)
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString, "username": self.userName, "phno": self.phno,"DOB": self.birthDate] as [String : Any]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err.localizedDescription)"
                    showError = true
                    return
                }
                print("Success")
                
                self.didCompleteLogin()
            }
    }
    private func validView() -> String? {
        
        if isLoginMode{
            if email.isEmpty {
                return "Email should not be empty"
            }
            
            else if !self.isValidEmail(email) {
                return "Email is invalid please enter correct Email address"
            }
            
            else if password.isEmpty {
                return "Password is empty"
            }
            else if self.password.count < 6 {
                return "Password should be 6 character long"
            }
        }else{
            if email.isEmpty {
                return "Email should not be empty"
            }
            
            else if !self.isValidEmail(email) {
                return "Email is invalid please enter correct Email address"
            }
            
            else if password.isEmpty {
                return "Password is empty"
            }
            else if userName.isEmpty{
                return "user name is empty"
            }
            else if phno.isEmpty{
                return "Phone number is empty"
            }
            else if !self.isValidPhoneNo(value: phno) {
                return "Phone number is invalid please enter correct phone number"
            }
            
            else if self.password.count < 6 {
                return "Password should be 6 character long"
            }

        }
        return nil
    }
    
    private func isValidPhoneNo(value: String) -> Bool {
                let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
                let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
                let result = phoneTest.evaluate(with: value)
                return result
            }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLogin: {
            
        })
    }
}
