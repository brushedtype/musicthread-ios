//
//  API.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import KeychainAccess

public class API {

    let baseURL: URL
    let client: ClientCredentials
    let keychain: Keychain

    private let tokenStore: TokenStore

    public func isAuthenticated() async -> Bool {
        return await self.tokenStore.isAuthenticated
    }


    public init(client: ClientCredentials, keychain: Keychain) {
        self.baseURL = client.baseURL.appendingPathComponent("/api")
        self.client = client
        self.keychain = keychain
        self.tokenStore = TokenStore(authBaseURL: self.client.baseURL.appendingPathComponent("/oauth"), keychain: keychain)

    }

    public func setAuth(_ tokenResponse: TokenResponse) async throws {
        try await self.tokenStore.setAuth(tokenResponse)
    }


    // MARK: - Authed Requests

    public func fetchThreads() async throws -> ThreadListResponse {
        guard await self.isAuthenticated() else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            throw err
        }

        let accessToken = try await self.tokenStore.fetchAccessToken(client: self.client)

        var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/threads"))
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(ThreadListResponse.self, from: data)
    }

    public func fetchBookmarks() async throws -> ThreadListResponse {
        guard await self.isAuthenticated() else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            throw err
        }

        let accessToken = try await self.tokenStore.fetchAccessToken(client: self.client)

        var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/bookmarks"))
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(ThreadListResponse.self, from: data)
    }

    public func createThread(title: String, description: String?, tags: [String], isPrivate: Bool) async throws -> ThreadResponse {
        guard await self.isAuthenticated() else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            throw err
        }

        let accessToken = try await self.tokenStore.fetchAccessToken(client: self.client)

        let reqBody = CreateThreadRequest(title: title, description: description ?? "", tags: tags, isPrivate: isPrivate)

        let jsonEncoder = JSONEncoder()

        var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/new-thread"))
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try jsonEncoder.encode(reqBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(ThreadResponse.self, from: data)
    }

    public func updateBookmark(threadKey: String, isBookmarked: Bool) async throws -> UpdateBookmarkResponse {
        guard await self.isAuthenticated() else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            throw err
        }

        let accessToken = try await self.tokenStore.fetchAccessToken(client: self.client)

        let reqBody = UpdateBookmarkRequest(threadKey: threadKey, isBookmarked: isBookmarked)

        let jsonEncoder = JSONEncoder()

        var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/update-bookmark"))
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try jsonEncoder.encode(reqBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(UpdateBookmarkResponse.self, from: data)
    }

    public func submitLink(threadKey: String, linkURL: String) async throws -> LinkResponse {
        guard await self.isAuthenticated() else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            throw err
        }

        let accessToken = try await self.tokenStore.fetchAccessToken(client: self.client)

        let reqBody = SubmitMusicLinkRequest(threadKey: threadKey, linkURL: linkURL)

        let jsonEncoder = JSONEncoder()

        var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/add-link"))
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try jsonEncoder.encode(reqBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(LinkResponse.self, from: data)
    }


    // MARK: - Unauthed Requests

    public func fetchFeatured() async throws -> ThreadListResponse {
        let request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/featured"))

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(ThreadListResponse.self, from: data)
    }

    public func fetchThread(key: String) async throws -> ThreadResponse {
        guard await self.isAuthenticated() else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            throw err
        }

        let accessToken = try await self.tokenStore.fetchAccessToken(client: self.client)

        var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/thread/" + key))
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(ThreadResponse.self, from: data)
    }

}

// MARK: - Response Types

public struct Account: Decodable {
    public let name: String
}

public struct Thread: Decodable {
    public let key: String
    public let title: String
    public let description: String
    public let tags: [String]
    public let isPrivate: Bool
    public let author: Account
    public let pageURL: URL

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case tags
        case isPrivate = "is_private"
        case author
        case pageURL = "page_url"
    }
}

public struct ThreadListResponse: Decodable {
    public let threads: [Thread]
}

public struct Link: Decodable {
    public let key: String
    public let title: String
    public let artist: String
    public let thumbnailURL: URL?
    public let pageURL: URL

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case artist
        case thumbnailURL = "thumbnail_url"
        case pageURL = "page_url"
    }
}

public struct ThreadResponse: Decodable {
    public let thread: Thread
    public let links: [Link]
}

public struct UpdateBookmarkResponse: Decodable {
    public let isBookmarked: Bool

    enum CodingKeys: String, CodingKey {
        case isBookmarked = "is_bookmarked"
    }
}


public struct LinkResponse: Decodable {
    public let link: Link

    enum CodingKeys: String, CodingKey {
        case link
    }
}


// MARK: - Request Types

struct SubmitMusicLinkRequest: Codable {
    let threadKey: String
    let linkURL: String

    enum CodingKeys: String, CodingKey {
        case threadKey = "thread"
        case linkURL = "url"
    }
}

struct CreateThreadRequest: Codable {
    let title: String
    let description: String
    let tags: [String]
    let isPrivate: Bool

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case tags
        case isPrivate = "is_private"
    }
}

struct UpdateBookmarkRequest: Codable {
    let threadKey: String
    let isBookmarked: Bool

    enum CodingKeys: String, CodingKey {
        case threadKey = "thread"
        case isBookmarked = "is_bookmarked"
    }
}
