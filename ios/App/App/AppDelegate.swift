//
//  AppDelegate.swift
//  App
//
//  Created by saik0 on 11/30/25.
//
import GiphRsCore
import UniFFI
import SDWebImage
import SDWebImageWebPCoder

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UniFFI.initialize()
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        return true
    }
}
