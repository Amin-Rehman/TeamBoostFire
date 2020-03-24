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
import TeamBoostKit

let testModeKey = "TestModeKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // A boolean to pre-populate the UI with a pre-set meeting environment
    var testEnvironment = false

    var window: UIWindow?
    public var participantCoreServices: ParticipantCoreServices?
    public var analyticsServices: AnalyticsService?
    public var teamBoostKitDomain: TeamBoostKitDomain?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppTestModeFromUserDefaultsIfNeeded()
        setupSingletonServices()
        return true
    }

    func setupSingletonServices() {
        FirebaseApp.configure()
        participantCoreServices = ParticipantCoreServices.shared
        analyticsServices = AnalyticsService.shared
    }

    func setupAppTestModeFromUserDefaultsIfNeeded() {
        let isTestModeEnabledAlready = UserDefaults.standard.value(forKey: testModeKey) as? Bool == true
        self.testEnvironment = isTestModeEnabledAlready
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

extension AppDelegate {
    public func makeHostDomain(referenceObserver: FirebaseReferenceObserver,
                               referenceHolder: FirebaseReferenceHolder,
                               meetingIdentifier: String,
                               meetingParams: MeetingsParams) {

        self.teamBoostKitDomain = TeamBoostKitDomain.make(referenceObserver: referenceObserver,
                                          referenceHolder: referenceHolder,
                                          meetingIdentifier: meetingIdentifier,
                                          meetingParams: meetingParams)

    }
}
