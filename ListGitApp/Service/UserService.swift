//
//  UserService.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import Foundation

/// Protocol defining methods for fetching user-related data asynchronously.
protocol UserServiceProtocol {
    /// Fetches a list of users from the GitHub API.
    /// - Returns: An array of User objects fetched from the API.
    func fetchUsers() async throws -> [User]
    
    /// Fetches detailed profile information for a specific user from the GitHub API.
    /// - Parameter userName: The username of the user whose profile is to be fetched.
    /// - Returns: A UserProfile object containing detailed profile information, or nil if not found.
    func fetchProfileUser(userName: String) async throws -> UserProfile?
}

/// Service for fetching user-related data from the GitHub API.
struct UserService: UserServiceProtocol {
    
    /// Private helper method to fetch data of a specific type from a given URL.
    /// - Parameters:
    ///   - type: The type of data to decode from the response.
    ///   - urlString: The URL string to fetch data from.
    /// - Returns: An object of the specified type decoded from the API response, or nil if unsuccessful.
    private func fetch<T: Decodable>(type: T.Type, from urlString: String) async -> T? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JsonUtilities.decodeJSON(type: type, from: data)
        } catch {
            print("Error fetching data from \(urlString): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Fetches a list of users from the GitHub API.
    /// - Returns: An array of User objects fetched from the GitHub API, or an empty array if unsuccessful.
    func fetchUsers() async throws -> [User] {
        await fetch(type: [User].self, from: "https://api.github.com/users") ?? []
    }
    
    /// Fetches detailed profile information for a specific user from the GitHub API.
    /// - Parameter userName: The username of the user whose profile is to be fetched.
    /// - Returns: A UserProfile object containing detailed profile information, or nil if the user does not exist.
    func fetchProfileUser(userName: String) async throws -> UserProfile? {
        return await fetch(type: UserProfile.self, from: "https://api.github.com/users/\(userName)")
    }
}
