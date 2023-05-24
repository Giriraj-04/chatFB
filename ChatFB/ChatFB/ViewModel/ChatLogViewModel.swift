//
//  File.swift
//  ChatFB
//
//  Created by vvdn on 20/04/23.
//

import Foundation
import UIKit
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var image: UIImage?
    @Published var chatMessages = [ChatMessage]()
    var chatUser: ChatUser?
    var imageurl = ""
    var groupid = ""
    @Published var isloading = false
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        if fromId.compare(toId, options: .caseInsensitive) == .orderedDescending {
            groupid = "\(fromId) - \(toId)"
                print("if\(groupid)")
        }else{
             groupid = "\(toId) - \(fromId)"
                print("else\(groupid)")
        }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(groupid)
            .collection(groupid)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error.localizedDescription)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        print("called")
                        do {
                            let cm = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(cm)
                            print("Appending chatMessage in ChatLogView: \(Date())")
                            if FirebaseManager.shared.auth.currentUser?.uid != cm.fromId {
                                change.document.reference.updateData(["seen": true])
                        }
                        } catch {
                            print("Failed to decode message: \(error.localizedDescription)")
                        }
                    }else if change.type == .modified{
                        do {
                            let cm = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.removeAll(where: {$0.id == cm.id})
                            if FirebaseManager.shared.auth.currentUser?.uid != cm.fromId {
                                change.document.reference.updateData(["seen": true])
                                
                        }
                            self.chatMessages.append(cm)
                    print("***** modified \(change.document.data())")
                        }catch {
                            print("Failed to decode message: \(error.localizedDescription)")
                        }
                    }
                    
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
        if let image = self.image{
            self.isloading = true
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            
            guard let toId = chatUser?.uid else { return }
            
            if fromId.compare(toId, options: .caseInsensitive) == .orderedDescending {
                 groupid = "\(fromId) - \(toId)"
                    print("if\(groupid)")
            }else{
                 groupid = "\(toId) - \(fromId)"
                    print("else\(groupid)")
            }
            
            let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                .document(groupid)
                .collection(groupid)
                .document()
                    
            let image = self.image
            let imageData = image?.jpegData(compressionQuality: 0.5)
            let imageName = UUID().uuidString + ".jpg"
            let imageRef = FirebaseManager.shared.storage.reference().child(imageName)

            // Upload the file to the path "images/imageName.jpg"
            let uploadTask = imageRef.putData(imageData!, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    self.imageurl = downloadURL.absoluteString
                    print(downloadURL.absoluteString)
                    // Save the download URL to the Firestore database
                    // with the message data.
    //                let message = Message(content: "", senderID: senderID, timestamp: Date(), imageURL: downloadURL.absoluteString)
                    let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: self.chatText, timestamp: Date(), seen: false, images: self.imageurl)
                    print(msg)
                    // Add the message to the chat log in your Firestore database.
                    
                    try? document.setData(from: msg) { error in
                        if let error = error {
                            print(error)
                            self.errorMessage = "Failed to save message into Firestore: \(error)"
                            return
                        }
                        
                        print("Successfully saved current user sending message")
                        
                        self.persistRecentMessage()
                        
                        self.chatText = ""
                        self.image = nil
                        self.count += 1
                        self.isloading = false
                    }
                    
                }
            }
            print(chatText)
        }else{
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            
            guard let toId = chatUser?.uid else { return }
            
            if fromId.compare(toId, options: .caseInsensitive) == .orderedDescending {
                 groupid = "\(fromId) - \(toId)"
                    print("if\(groupid)")
            }else{
                 groupid = "\(toId) - \(fromId)"
                    print("else\(groupid)")
            }
            
            let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                .document(groupid)
                .collection(groupid)
                .document()
            let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: self.chatText, timestamp: Date(), seen: false, images: "")
            print(msg)
            // Add the message to the chat log in your Firestore database.
            
            try? document.setData(from: msg) { error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to save message into Firestore: \(error)"
                    return
                }
                
                print("Successfully saved current user sending message")
                
                self.persistRecentMessage()
                
                self.chatText = ""
                self.image = nil
                self.count += 1
            }
            
//            let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
//                .document(groupid)
//                .collection(groupid)
//                .document()

//            try? recipientMessageDocument.setData(from: msg) { error in
//                if let error = error {
//                    print(error)
//                    self.errorMessage = "Failed to save message into Firestore: \(error)"
//                    return
//                }
//
//                print("Recipient saved message as well")
//            }
        }
    }

    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.images: self.imageurl,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        // you'll need to save another very similar dictionary for the recipient of this message...how?
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.images: self.imageurl,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.email: currentUser.email
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    
    @Published var count = 0
}
