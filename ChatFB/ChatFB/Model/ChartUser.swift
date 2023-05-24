//
//  ChartUser.swift
//  ChatFB
//
//  Created by vvdn on 16/04/23.
//

import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid }
    
    let uid, email, profileImageUrl, userName, phno: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.userName = data["username"] as? String ?? ""
        self.phno = data["phno"] as? String ?? ""
    }
}
