//
//  AppDelegate.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//



import UIKit
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // A boolean to pre-populate the UI with a pre-set meeting environment
    // Only for development
    var testEnvironment = true

    var window: UIWindow?
    public var coreServices: CoreServices?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        coreServices = CoreServices.shared
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

