//
//  UserStatusViewModel.swift
//  ChatFB
//
//  Created by vvdn on 20/04/23.
//

import Foundation
import Firebase
import FirebaseDatabase

class UserStatusViewModel: ObservableObject {
    var uid = FirebaseManager.shared.auth.currentUser?.uid
    var ref: DatabaseReference?
    @Published var isUserOnline = false

    init(uid:String) {
        self.uid = uid
        ref = Database.database().reference().child("presence").child(uid)
            ref?.child("isOnline").setValue(true)
//        setonline()
        updateUserPresence()
        fetchuserstatus()
    }
    
    func setonline(){
        ref = Database.database().reference().child("presence").child(uid!)
            ref?.child("isOnline").setValue(true)
//        ref?.child("lastOnline").setValue()
    }
    
    
    func updateUserPresence() {
            if let ref = ref {
                let isOnline = false
                let lastOnline = ServerValue.timestamp()
                ref.child("isOnline").setValue(isOnline)
                ref.child("lastOnline").setValue(lastOnline)
            }
        }
    
    func fetchuserstatus(){
        
        ref = Database.database().reference().child("presence").child(uid!)
        ref?.observe(.value, with: { snapshot in
            if let value = snapshot.value as? [String: Any],
               let isOnline = value["isOnline"] as? Bool {
                self.isUserOnline = isOnline
            }
        })
    }
}
