//
//  UserGit.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import Foundation

struct User: Codable, Identifiable {
    let login: String
    let id: Int
    let avatarURL: String
    let htmlURL: String


    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}
