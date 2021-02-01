//
//  API.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import KeychainAccess

class API {

    let baseURL: URL
    let client: ClientCredentials
    let keychain: Keychain

    private var tokenStore: TokenStore?

    var isAuthenticated: Bool {
        return self.tokenStore != nil
    }


    init(baseURL: URL, client: ClientCredentials, keychain: Keychain) {
        self.baseURL = baseURL
        self.client = client
        self.keychain = keychain

        if let refreshToken = try? self.keychain.get("refresh_token") {
            self.setTokenStore(TokenStore(authBaseURL: self.client.baseURL.appendingPathComponent("/oauth"), refreshToken: refreshToken))
        }
    }

    func setTokenStore(_ tokenStore: TokenStore) {
        if Foundation.Thread.isMainThread {
            self.tokenStore = tokenStore
        } else {
            DispatchQueue.main.sync {
                self.tokenStore = tokenStore
            }
        }
    }

    func fetchThreads(completion: @escaping (Result<ThreadListResponse, Error>) -> Void) {
        guard let tokenStore = self.tokenStore else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth: tokenStore was not set"])
            return completion(.failure(err))
        }

        tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
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

    func fetchBookmarks(completion: @escaping (Result<ThreadListResponse, Error>) -> Void) {
        guard let tokenStore = self.tokenStore else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth: tokenStore was not set"])
            return completion(.failure(err))
        }

        tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
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

    func createThread(title: String, completion: @escaping (Result<ThreadResponse, Error>) -> Void) {
        guard let tokenStore = self.tokenStore else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth: tokenStore was not set"])
            return completion(.failure(err))
        }

        tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let accessToken):
                let reqBody = CreateThreadRequest(title: title, description: "", tags: [])

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

    func updateBookmark(threadKey: String, isBookmarked: Bool, completion: @escaping (Result<UpdateBookmarkResponse, Error>) -> Void) {
        guard let tokenStore = self.tokenStore else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth: tokenStore was not set"])
            return completion(.failure(err))
        }

        tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
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

    func submitLink(threadKey: String, linkURL: String, completion: @escaping (Result<LinkResponse, Error>) -> Void) {
        guard let tokenStore = self.tokenStore else {
            let err = NSError(domain: "co.brushedtype.musicthread", code: -3333, userInfo: [NSLocalizedDescriptionKey: "method requires auth: tokenStore was not set"])
            return completion(.failure(err))
        }

        tokenStore.fetchAccessToken(client: self.client, keychain: self.keychain) { (result) in
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

    func fetchFeatured(completion: @escaping (Result<ThreadListResponse, Error>) -> Void) {
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

    func fetchThread(key: String, completion: @escaping (Result<ThreadResponse, Error>) -> Void) {
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

struct Account: Decodable {
    let name: String
}

struct Thread: Decodable {
    let key: String
    let title: String
    let description: String
    let tags: [String]
    let author: Account
    let pageURL: URL

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case description
        case tags
        case author
        case pageURL = "page_url"
    }
}

struct ThreadListResponse: Decodable {
    let threads: [Thread]
}

struct Link: Decodable {
    let key: String
    let title: String
    let artist: String
    let thumbnailURL: URL
    let pageURL: URL

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case artist
        case thumbnailURL = "thumbnail_url"
        case pageURL = "page_url"
    }
}

struct ThreadResponse: Decodable {
    let thread: Thread
    let links: [Link]
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

struct UpdateBookmarkResponse: Decodable {
    let isBookmarked: Bool

    enum CodingKeys: String, CodingKey {
        case isBookmarked = "is_bookmarked"
    }
}

struct SubmitMusicLinkRequest: Codable {
    let threadKey: String
    let linkURL: String

    enum CodingKeys: String, CodingKey {
        case threadKey = "thread"
        case linkURL = "url"
    }
}

struct LinkResponse: Decodable {
    let link: Link

    enum CodingKeys: String, CodingKey {
        case link
    }
}
