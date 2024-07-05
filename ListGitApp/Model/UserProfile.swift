//
//  U.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//
import Foundation

struct UserProfile: Codable, Identifiable {
    let login: String
    let id: Int
    let name: String
    let location: String
    let bio: String
    let publicRepos: Int
    let publicGists: Int
    let followers: Int
    let following: Int

    enum CodingKeys: String, CodingKey {
        case login, id
        case name, location, bio
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers, following
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        login = try container.decodeIfPresent(String.self, forKey: .login) ?? ""
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        publicRepos = try container.decodeIfPresent(Int.self, forKey: .publicRepos) ?? 0
        publicGists = try container.decodeIfPresent(Int.self, forKey: .publicGists) ?? 0
        followers = try container.decodeIfPresent(Int.self, forKey: .followers) ?? 0
        following = try container.decodeIfPresent(Int.self, forKey: .following) ?? 0
    }
}
