//
//  HomeOrganizerApp.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/23/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct HomeOrganizerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var houseVM = HouseViewModel()
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(houseVM)
        }
    }
}
