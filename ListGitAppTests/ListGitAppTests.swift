//
//  ListGitAppTests.swift
//  ListGitAppTests
//
//  Created by phuchieu on 5/7/24.
//

import XCTest
@testable import ListGitApp


final class ListGitAppTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    // 1. Write a test to ensure total amount of all users are loaded
    func testTotalUsers() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "https://api.github.com/users")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, self.loadFixture(named: "GithubUsers")!)
        }
        
        let expectation = XCTestExpectation(description: "Fetch users")
        
        let userModel = UsersViewModel()
        await userModel.fetchUsersAndProfile(isConnected: true)
        
        // Wait for the async fetch operation to complete
        DispatchQueue.main.async {
            XCTAssertEqual(userModel.users.count, 30, "total amount of all users are loaded not equal expected")
            expectation.fulfill()
            
        }
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // 2. Write a test assert following, follower of a user
    func testFollowUsers() async throws {
        URLProtocol.registerClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "https://api.github.com/users/mojombo")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, self.loadFixture(named: "GithubUser_mojombo")!)
        }
        
        let expectation = XCTestExpectation(description: "Fetch user profile")
        
        let userProfile = try await UserService().fetchProfileUser(userName: "mojombo")
        
        // Wait for the async fetch operation to complete
        DispatchQueue.main.async {
            XCTAssertEqual(userProfile?.followers, 23933 , "Not Equal followers of user")
            XCTAssertEqual(userProfile?.following, 11 , "Not Equal followering of user")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}

extension XCTestCase {
    func loadFixture(named name: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: name, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: path)
    }
}


final class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response,
                                cacheStoragePolicy: .notAllowed)
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
    }
}
