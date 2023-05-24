//
//  OnlineOfflineService.swift
//  ChatFB
//
//  Created by vvdn on 20/04/23.
//

import Foundation
import UIKit
import FirebaseDatabase

struct OnlineOfflineService {
    static func online(for uid: String, status: Bool, success: @escaping (Bool) -> Void) {
        //True == Online, False == Offline
        let onlinesRef = Database.database().reference().child(uid).child("isOnline")
        onlinesRef.setValue(status) {(error, _ ) in

            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            success(true)
        }
    }
}
