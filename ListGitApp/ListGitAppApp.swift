//
//  ListGitAppApp.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import SwiftUI

@main
struct ListGitAppApp: App {
    @StateObject var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
        }
    }
}
