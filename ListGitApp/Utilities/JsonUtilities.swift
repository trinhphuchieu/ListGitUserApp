//
//  JsonUtilities.swift
//  ListGitApp
//
//  Created by phuchieu on 4/7/24.
//

import Foundation

/// Utility functions for JSON encoding, decoding, and offline data saving.
class JsonUtilities {
    
    /// Decode JSON data into a specific type.
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - data: The JSON data to decode.
    /// - Returns: An instance of the specified type decoded from JSON data.
    static public func decodeJSON<T: Decodable>(type: T.Type, from data: Data) throws -> T {
        return try JSONDecoder().decode(type, from: data)
    }
    
    /// Encode data of a specific type into JSON format.
    /// - Parameter data: The data to encode into JSON.
    /// - Returns: JSON data representation of the input.
    static public func encodeData<T: Encodable>(_ data: T) throws -> Data {
        return try JSONEncoder().encode(data)
    }
    
    /// Save data offline using UserDefaults asynchronously.
    /// - Parameters:
    ///   - data: The data to save offline.
    ///   - key: The key under which to store the data in UserDefaults.
    static func saveOfflineData<T: Encodable>(data: T, forKey key: String) async throws {
        let jsonData = try encodeData(data)
        UserDefaults.standard.set(jsonData, forKey: key)
    }
}
