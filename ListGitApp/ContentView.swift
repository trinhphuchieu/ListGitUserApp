//
//  ContentView.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userModel = UsersViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        NavigationView {
            List(userModel.users) { user in
                NavigationLink(
                    destination: UserProfileView(user: user)
                        .environmentObject(userModel)
                        .environmentObject(networkMonitor)
                ) {
                    RowUserProfileView(user: user)
                        .environmentObject(userModel)
                }
            }
            .navigationBarTitle("User List", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "line.3.horizontal")
                }
            }
            .task {
                await fetchUserData()
            }
            .refreshable {
                await fetchUserData()
            }
        }
    }
    
    private func fetchUserData() async {
        await userModel.fetchUsersAndProfile(isConnected: networkMonitor.isConnected)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UsersViewModel())
            .environmentObject(NetworkMonitor())
    }
}
