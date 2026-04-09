//
//  AppApp.swift
//  App
//
//  Created by saik0 on 10/9/25.
//

import SwiftUI

@main
struct AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: SwiftViewModel())
        }
    }
}
