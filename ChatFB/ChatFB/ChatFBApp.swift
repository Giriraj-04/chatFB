//
//  ChatFBApp.swift
//  ChatFB
//
//  Created by vvdn on 19/04/23.
//

import SwiftUI

import SwiftUI

@main
struct myApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainMessageView()
        }
    }
}
