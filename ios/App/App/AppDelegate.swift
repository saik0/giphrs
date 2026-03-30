//
//  AppDelegate.swift
//  App
//
//  Created by saik0 on 11/30/25.
//
import GiphRsCore
import UniFFI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UniFFI.initialize()
        return true
    }
}
