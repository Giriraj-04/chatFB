//
//  MainMessageViewModel.swift
//  ChatFB
//
//  Created by vvdn on 20/04/23.
//

import Foundation
import Firebase
import FirebaseDatabase


class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var userstatus = [UserStatus]()
    @Published var showError = false
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        
        fetchRecentMessages()
    
        setUserOnline()

       
        if !self.isUserCurrentlyLoggedOut{
            setUserOnline()
            updateOnlineUser()
        }
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        self.userstatus.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                         let rm = try change.document.data(as: RecentMessage.self)
                            self.recentMessages.insert(rm, at: 0)
                        
                    } catch {
                        print(error)
                        self.showError = true
                    }
                })
            }
        updateOnlineUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                self.showError = true
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                self.showError = true
                return
                
            }
            
            self.chatUser = .init(data: data)
            FirebaseManager.shared.currentUser = self.chatUser
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        if FirebaseManager.shared.auth.currentUser != nil {
            OnlineOfflineService.online(for: (Auth.auth().currentUser?.uid)!, status:false){ (success) in
                print("User ==>", success)
            }
        }
        try? FirebaseManager.shared.auth.signOut()
        updateOnlineUser()

    }
    
    let userref = FirebaseManager.shared.database.reference(withPath: "online")
    
    func setUserOnline(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
//            self.showError = true
            return
        }
        
        if FirebaseManager.shared.auth.currentUser != nil {
            OnlineOfflineService.online(for: (Auth.auth().currentUser?.uid)!, status:true){ (success) in
                print("User ==>", success)
                
            }
        }
    }
    func updateOnlineUser(){
        self.userstatus.removeAll()
        FirebaseManager.shared.database.reference().observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let value = snap.value as? [String: Bool] {
                        print(value)
                        let data = snap.key
                        print(data)                        
                        self.userstatus.append(UserStatus.init(uid: data, isOnline: value))
                    }
                }
            print(self.userstatus)
            })
    }
    
}


