//
//  UsersViewModel.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import Foundation

/// ViewModel for managing users and their profiles.
class UsersViewModel: ObservableObject {
    // Dependencies
    let userService: UserServiceProtocol
    let userStorage: UserStorageProtocol
    
    // Published properties to update the UI
    @Published var users: [User] = []
    @Published var usersProfile: [UserProfile] = []
    
    // Keys for storing offline data
    private let keyUsers = "UserList"
    private let keyUsersProfile = "UserProfile"
    
    // Initialization with default services
    init(userService: UserServiceProtocol = UserService(), userStorage: UserStorageProtocol = UserStorage()) {
        self.userService = userService
        self.userStorage = userStorage
    }
    
    /// Fetches users and their profiles from API or local storage based on the internet connection.
    /// - Parameter isConnected: Boolean indicating if the device is connected to the internet.
    func fetchUsersAndProfile(isConnected: Bool) async {
        do {
            // Variables to store fetched data
            let fetchedUsers: [User]
            let fetchedProfiles: [UserProfile?]
            
            if isConnected {
                // Fetch from API if connected
                fetchedUsers = try await fetchUserFromAPI()
                fetchedProfiles = try await fetchProfiles(for: users)
            } else {
                // Load from local storage if not connected
                fetchedUsers = try await userStorage.loadOfflineData(forKey: keyUsers, as: [User].self)
                fetchedProfiles = try await userStorage.loadOfflineData(forKey: keyUsersProfile, as: [UserProfile].self)
            }
            
            // Update UI on the main thread
            await MainActor.run {
                self.users = fetchedUsers
                self.usersProfile = fetchedProfiles.compactMap { $0 }
            }
            
            if isConnected {
                // Save fetched data to local storage if connected
                try await userStorage.saveOfflineData(data: users, forKey: keyUsers)
                try await userStorage.saveOfflineData(data: usersProfile, forKey: keyUsersProfile)
            }
            
        } catch {
            // Handle errors
            print("Error fetching users: \(error.localizedDescription)")
        }
    }
    
    /// Fetches profiles for the given users asynchronously.
    /// - Parameter users: Array of `User` objects.
    /// - Returns: Array of optional `UserProfile` objects.
    func fetchProfiles(for users: [User]) async throws -> [UserProfile?] {
        var profiles: [UserProfile?] = []
        
        // Use a task group to fetch profiles concurrently
        await withTaskGroup(of: UserProfile?.self) { group in
            for user in users {
                group.addTask {
                    do {
                        // Fetch profile for each user
                        return try await self.userService.fetchProfileUser(userName: user.login)
                    } catch {
                        // Handle errors and return nil
                        print("Error fetching profile for \(user.login): \(error)")
                        return nil
                    }
                }
            }
            
            // Collect results from the task group
            for await result in group {
                profiles.append(result)
            }
        }
        
        return profiles
    }
    
    // Actor to manage failed users when loading images
    actor UserErrorManager {
        private var failedUsers: [User] = []
        
        /// Adds a user to the list of failed users.
        /// - Parameter user: The `User` object that failed to load.
        func addFailedUser(_ user: User) {
            failedUsers.append(user)
        }
        
        /// Retrieves the list of failed users.
        /// - Returns: Array of `User` objects.
        func getFailedUsers() -> [User] {
            return failedUsers
        }
    }
    
    /// Fetches users from the API asynchronously.
    /// - Returns: Array of `User` objects.
    func fetchUserFromAPI() async throws -> [User] {
        // Fetch users from API
        let users = try await userService.fetchUsers()
        let errorManager = UserErrorManager()
        
        // Update UI on the main thread
        DispatchQueue.main.async {
            self.users = users
        }
        
        // Use a task group to fetch user images concurrently
        await withThrowingTaskGroup(of: Void.self) { group in
            for user in users {
                group.addTask {
                    guard let url = URL(string: user.avatarURL) else {
                        // Handle invalid URL
                        throw URLError(.badURL)
                    }
                    
                    do {
                        // Fetch and save user image
                        let (imageData, _) = try await URLSession.shared.data(from: url)
                        self.userStorage.saveImageToDisk(imageData, fileName: "avatar_\(user.id).jpg")
                    } catch {
                        // Handle errors and add to failed users
                        print("Error fetching image for user \(user.id): \(error.localizedDescription)")
                        await errorManager.addFailedUser(user)
                    }
                }
            }
        }
        
        // Check for failed users and log errors
        let failedUsers = await errorManager.getFailedUsers()
        if !failedUsers.isEmpty {
            print("Failed to fetch images for users: \(failedUsers.map { $0.id })")
        }
        
        return users
    }
    
    /// Refreshes the profile of a specific user.
    /// - Parameter userName: The login username of the user.
    func refreshUserProfile(userName: String) async {
        // Find the index of the user profile
        guard let index = usersProfile.firstIndex(where: { $0.login == userName }) else {
            return
        }
        
        do {
            // Fetch and update user profile
            if let userProfile = try await self.userService.fetchProfileUser(userName: userName) {
                self.usersProfile[index] = userProfile
                // Save updated profiles to local storage
                try await userStorage.saveOfflineData(data: self.usersProfile, forKey: keyUsersProfile)
            }
        } catch {
            // Handle errors
            print("Error refreshing user profile: \(error.localizedDescription)")
        }
    }
    
    /// Retrieves the profile of a specific user.
    /// - Parameter userName: The login username of the user.
    /// - Returns: An optional `UserProfile` object if found.
    func getUserProfiles(userName: String) async -> UserProfile? {
        // Find and return the user profile
        guard let userProfile = self.usersProfile.first(where: { $0.login == userName }) else {
            return nil
        }
        return userProfile
    }
}
