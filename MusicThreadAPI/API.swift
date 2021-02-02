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

    public var isAuthenticated: Bool {
        return self.tokenStore.isAuthenticated
    }


    public init(client: ClientCredentials, keychain: Keychain) {
        self.baseURL = client.baseURL.appendingPathComponent("/api")
        self.client = client
        self.keychain = keychain
        self.tokenStore = TokenStore(authBaseURL: self.client.baseURL.appendingPathComponent("/oauth"), keychain: keychain)

    }

    public func setAuth(_ tokenResponse: TokenResponse) throws {
        if Foundation.Thread.isMainThread {
            try self.tokenStore.setAuth(tokenResponse)
        } else {
            try DispatchQueue.main.sync {
                try self.tokenStore.setAuth(tokenResponse)
            }
        }
    }


    // MARK: - Authed Requests

    public func fetchThreads(completion: @escaping (Result<ThreadListResponse, Error>) -> Void) {
        guard self.isAuthenticated else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            return completion(.failure(err))
        }

        self.tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/threads"))
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil, let data = data else {
                        let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                        return completion(.failure(err))
                    }

                    let jsonDecoder = JSONDecoder()
                    let result = jsonDecoder.decodeResult(ThreadListResponse.self, from: data)

                    completion(result)
                }.resume()
            }
        }
    }

    public func fetchBookmarks(completion: @escaping (Result<ThreadListResponse, Error>) -> Void) {
        guard self.isAuthenticated else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            return completion(.failure(err))
        }

        self.tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/bookmarks"))
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil, let data = data else {
                        let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                        return completion(.failure(err))
                    }

                    let jsonDecoder = JSONDecoder()
                    let result = jsonDecoder.decodeResult(ThreadListResponse.self, from: data)

                    completion(result)
                }.resume()
            }
        }
    }

    public func createThread(title: String, description: String?, tags: [String], completion: @escaping (Result<ThreadResponse, Error>) -> Void) {
        guard self.isAuthenticated else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            return completion(.failure(err))
        }

        self.tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                let reqBody = CreateThreadRequest(title: title, description: description ?? "", tags: tags)

                let jsonEncoder = JSONEncoder()

                var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/new-thread"))
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                request.httpBody = try? jsonEncoder.encode(reqBody)

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil, let data = data else {
                        let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                        return completion(.failure(err))
                    }

                    let jsonDecoder = JSONDecoder()
                    let result = jsonDecoder.decodeResult(ThreadResponse.self, from: data)

                    completion(result)
                }.resume()
            }
        }
    }

    public func updateBookmark(threadKey: String, isBookmarked: Bool, completion: @escaping (Result<UpdateBookmarkResponse, Error>) -> Void) {
        guard self.isAuthenticated else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            return completion(.failure(err))
        }

        self.tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                let reqBody = UpdateBookmarkRequest(threadKey: threadKey, isBookmarked: isBookmarked)

                let jsonEncoder = JSONEncoder()

                var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/update-bookmark"))
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                request.httpBody = try? jsonEncoder.encode(reqBody)

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil, let data = data else {
                        let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                        return completion(.failure(err))
                    }

                    let jsonDecoder = JSONDecoder()
                    let result = jsonDecoder.decodeResult(UpdateBookmarkResponse.self, from: data)

                    completion(result)
                }.resume()
            }
        }
    }

    public func submitLink(threadKey: String, linkURL: String, completion: @escaping (Result<LinkResponse, Error>) -> Void) {
        guard self.isAuthenticated else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth"])
            return completion(.failure(err))
        }

        self.tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                let reqBody = SubmitMusicLinkRequest(threadKey: threadKey, linkURL: linkURL)

                let jsonEncoder = JSONEncoder()

                var request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/add-link"))
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                request.httpBody = try? jsonEncoder.encode(reqBody)

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil, let data = data else {
                        let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                        return completion(.failure(err))
                    }

                    let jsonDecoder = JSONDecoder()
                    let result = jsonDecoder.decodeResult(LinkResponse.self, from: data)

                    completion(result)
                }.resume()
            }
        }
    }


    // MARK: - Unauthed Requests

    public func fetchFeatured(completion: @escaping (Result<ThreadListResponse, Error>) -> Void) {
        let request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/featured"))

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data = data else {
                let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                return completion(.failure(err))
            }

            let jsonDecoder = JSONDecoder()
            let result = jsonDecoder.decodeResult(ThreadListResponse.self, from: data)

            completion(result)
        }.resume()
    }

    public func fetchThread(key: String, completion: @escaping (Result<ThreadResponse, Error>) -> Void) {
        let request = URLRequest(url: self.baseURL.appendingPathComponent("/v0/thread/" + key))

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data = data else {
                let err = error ?? NSError(domain: "co.brushedtype.musicthread", code: -3424, userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                return completion(.failure(err))
            }

            let jsonDecoder = JSONDecoder()
            let result = jsonDecoder.decodeResult(ThreadResponse.self, from: data)

            completion(result)
        }.resume()
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
    public let author: Account
    public let pageURL: URL

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case tags
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
    public let thumbnailURL: URL
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

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case tags
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
