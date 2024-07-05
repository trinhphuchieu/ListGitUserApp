//
//  UserStorage.swift
//  ListGitApp
//
//  Created by phuchieu on 5/7/24.
//

import Foundation

/// Protocol for managing user data storage, including offline data and images.
protocol UserStorageProtocol {
    
    /// Saves data offline using UserDefaults.
    /// - Parameters:
    ///   - data: The data to be saved.
    ///   - key: The key to store data in UserDefaults.
    func saveOfflineData<T: Encodable>(data: T, forKey key: String) async throws
    
    /// Loads offline data from UserDefaults.
    /// - Parameters:
    ///   - key: The key to load data from UserDefaults.
    ///   - type: The type of data to decode.
    /// - Returns: Decoded data or an empty array if no data found.
    func loadOfflineData<T: Decodable>(forKey key: String, as type: [T].Type) async throws -> [T]
    
    /// Saves an image to disk.
    /// - Parameters:
    ///   - data: The image data to save.
    ///   - fileName: The file name for the image.
    func saveImageToDisk(_ data: Data, fileName: String)
    
    /// Loads an image from disk.
    /// - Parameter userId: The user ID to find the image.
    /// - Returns: Image data if exists, nil otherwise.
    func loadImageFromDisk(userId: String) -> Data?
}

/// Manages user data storage including offline data and images.
class UserStorage: UserStorageProtocol {
    
    /// Saves data offline using UserDefaults.
    /// - Parameters:
    ///   - data: The data to be saved.
    ///   - key: The key to store data in UserDefaults.
    func saveOfflineData<T: Encodable>(data: T, forKey key: String) async throws {
        let jsonData = try JsonUtilities.encodeData(data)
        UserDefaults.standard.set(jsonData, forKey: key)
    }
    
    /// Loads offline data from UserDefaults.
    /// - Parameters:
    ///   - key: The key to load data from UserDefaults.
    ///   - type: The type of data to decode.
    /// - Returns: Decoded data or an empty array if no data found.
    func loadOfflineData<T: Decodable>(forKey key: String, as type: [T].Type) async throws -> [T] {
        if let data = UserDefaults.standard.data(forKey: key) {
            let decodedData = try JsonUtilities.decodeJSON(type: type, from: data)
            return decodedData
        }
        return []
    }
    
    /// Saves an image to disk.
    /// - Parameters:
    /// - data: The image data to save.
    /// - fileName: The file name for the image.
    func saveImageToDisk(_ data: Data, fileName: String) {
        let fileManager = FileManager.default
        let fileURL = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(fileName)
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
            try data.write(to: fileURL)
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    
    /// Loads an image from disk.
    /// - Parameter userId: The user ID to find the image.
    /// - Returns: Image data if exists, nil otherwise.
    func loadImageFromDisk(userId: String) -> Data? {
        let fileManager = FileManager.default
        let fileURL = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("avatar_\(userId).jpg")
        do {
            let imageData = try Data(contentsOf: fileURL)
            return imageData
        } catch {
            print("Error loading image from disk: \(error.localizedDescription)")
            return nil
        }
    }
}
