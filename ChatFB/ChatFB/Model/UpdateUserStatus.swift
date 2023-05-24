//
//  UpdateUserStatus.swift
//  ChatFB
//
//  Created by vvdn on 20/04/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct UserStatus: Identifiable {
    var id: String?
    var uid: String?
    var isOnline: [String:Bool]?
}




