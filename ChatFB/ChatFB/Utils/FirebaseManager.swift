//
//  FirebaseManager.swift
//  ChatFB
//
//  Created by vvdn on 16/04/23.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    let database: Database
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
//        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        self.database = Database.database()
        super.init()
    }
    
}
