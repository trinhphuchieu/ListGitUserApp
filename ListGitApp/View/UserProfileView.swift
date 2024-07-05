//
//  UserProfileView.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userModel: UsersViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var userProfile: UserProfile?
    @State private var showErrorAlert = false
    @State private var isRefreshing = false
    @State private var showNetworkAlert = false

    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: - HEADER
            headerView
            
            Divider()
            
            // MARK: - BODY
            bodyView
            
            Spacer()
            Divider()
            
            // MARK: - FOOTER
            footerView
        }
        .padding()
        .navigationBarBackButtonHidden()
        .navigationBarTitle("Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isRefreshing {
                    ProgressView()
                } else {
                    Button {
                        Task {
                            await refreshUserProfile()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .task {
            await fetchUserProfile()
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to fetch user profile. Please try again later."),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack {
            HStack {
                userImageView
                VStack(alignment: .leading) {
                    Text(userProfile?.name ?? "")
                        .font(.headline)
                    Text(userProfile?.location ?? "")
                        .font(.subheadline)
                }
            }
        }
    }
    
    @ViewBuilder
    private var bodyView: some View {
        VStack {
            Text("About")
            Text(userProfile?.bio ?? "")
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        VStack {
            Text("Stats")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                statView(title: "PUBLIC REPO", value: userProfile?.publicRepos ?? 0)
                Spacer()
                statView(title: "FOLLOWERS", value: userProfile?.followers ?? 0)
                Spacer()
                statView(title: "FOLLOWING", value: userProfile?.following ?? 0)
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private var userImageView: some View {
        if let imageData = userModel.userStorage.loadImageFromDisk(userId: "\(user.id)"),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        } else {
            AsyncImage(url: URL(string: user.avatarURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .background(Color.gray)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
        }
    }
    
    private func statView(title: String, value: Int) -> some View {
        VStack(alignment: .leading) {
            Text("\(value)")
                .font(.title3)
                .foregroundColor(.red)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(alignment: .leading)
    }
    
    private func fetchUserProfile() async {
        if let profile = await userModel.getUserProfiles(userName: user.login) {
            self.userProfile = profile
        } else {
            showErrorAlert.toggle()
        }
    }
    
    private func refreshUserProfile() async {
        if networkMonitor.isConnected {
            await userModel.refreshUserProfile(userName: user.login)
            await fetchUserProfile()
            return
        }
        print("hieu")
    }
}

#Preview {
    NavigationStack {
        UserProfileView(user: User(login: "defunkt",
                                   id: 2,
                                   avatarURL: "https://via.placeholder.com/50",
                                   htmlURL: "https://example.com/user1"))
        .environmentObject(UsersViewModel())
        .environmentObject(NetworkMonitor())
    }
}
