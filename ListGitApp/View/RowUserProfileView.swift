//
//  RowUserProfileView.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import SwiftUI

struct RowUserProfileView: View {
    @EnvironmentObject var userModel: UsersViewModel
    let user: User
    
    var body: some View {
        HStack {
            userImageView
            
            VStack(alignment: .leading) {
                Text(user.login)
                    .font(.headline)
                Text(user.htmlURL)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var userImageView: some View {
        if let imageData = userModel.userStorage.loadImageFromDisk(userId: "\(user.id)"),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
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
            .frame(width: 70, height: 70)
            .clipShape(Circle())
        }
    }
}

struct RowUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RowUserProfileView(user: User(login: "defunkt",
                                      id: 2,
                                      avatarURL: "https://via.placeholder.com/50",
                                      htmlURL: "https://example.com/user1"))
            .environmentObject(UsersViewModel())
            .previewLayout(.fixed(width: 300, height: 80))
            .padding()
    }
}
