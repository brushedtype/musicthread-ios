//
//  RootViewModel.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI
import KeychainAccess

class RootViewModel: ObservableObject {

    let client: ClientCredentials
    let keychain: Keychain
    let apiClient: API

    @Published var threads: [Thread] = []
    @Published var bookmarks: [Thread] = []
    @Published var featured: [Thread] = []


    init(client: ClientCredentials, keychain: Keychain) {
        self.client = client
        self.apiClient = API(baseURL: client.baseURL.appendingPathComponent("/api"), client: client, keychain: keychain)
        self.keychain = keychain

        if self.apiClient.isAuthenticated {
            self.fetchThreads()
            self.fetchBookmarks()
            self.fetchFeatured()
        }
    }

    func setAuth(tokenResponse: TokenResponse) {
        try? self.keychain.set(tokenResponse.refreshToken, key: "refresh_token")

        self.apiClient.setTokenStore(TokenStore(authBaseURL: self.client.baseURL.appendingPathComponent("/oauth"), tokenResponse: tokenResponse))

        self.fetchThreads()
        self.fetchBookmarks()
        self.fetchFeatured()
    }

    func fetchThreads() {
        guard self.apiClient.isAuthenticated else {
            return
        }

        self.apiClient.fetchThreads { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(let threadResponse):
                    self.threads = threadResponse.threads
                }
            }
        }
    }

    func fetchBookmarks() {
        guard self.apiClient.isAuthenticated else {
            return
        }

        self.apiClient.fetchBookmarks { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(let threadResponse):
                    self.bookmarks = threadResponse.threads
                }
            }
        }
    }

    func fetchFeatured() {
        guard self.featured.isEmpty else {
            return
        }

        self.apiClient.fetchFeatured { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(let threadResponse):
                    self.featured = threadResponse.threads
                }
            }
        }
    }

    func isThreadBookmarked(thread: Thread) -> Bool {
        guard self.apiClient.isAuthenticated else {
            return false
        }

        return self.bookmarks.contains(where: { $0.key == thread.key })
    }

    func isThreadOwn(thread: Thread) -> Bool {
        guard self.apiClient.isAuthenticated else {
            return false
        }

        return self.threads.contains(where: { $0.key == thread.key })
    }

}
