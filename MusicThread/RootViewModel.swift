//
//  RootViewModel.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI
import MusicThreadAPI
import KeychainAccess

actor RootViewModel: ObservableObject {

    let client: ClientCredentials
    let keychain: Keychain
    let apiClient: API

    @MainActor @Published var threads: [MusicThreadAPI.Thread] = []
    @MainActor @Published var bookmarks: [MusicThreadAPI.Thread] = []
    @MainActor @Published var featured: [MusicThreadAPI.Thread] = []


    init(client: ClientCredentials, keychain: Keychain) {
        self.client = client
        self.apiClient = API(client: client, keychain: keychain)
        self.keychain = keychain
    }

    func setAuth(tokenResponse: TokenResponse) async throws {
        try await self.apiClient.setAuth(tokenResponse)
        try await self.fetchInitialContent()
    }

    func fetchInitialContent() async throws {
        try await self.fetchThreads()
        try await self.fetchBookmarks()
        try await self.fetchFeatured()
    }

    @MainActor
    func fetchThreads() async throws {
        guard await self.apiClient.isAuthenticated() else {
            return
        }
        self.threads = try await self.apiClient.fetchThreads().threads
    }

    @MainActor
    func fetchBookmarks() async throws {
        guard await self.apiClient.isAuthenticated() else {
            return
        }
        self.bookmarks = try await self.apiClient.fetchBookmarks().threads
    }

    @MainActor
    func fetchFeatured() async throws {
        guard self.featured.isEmpty else {
            return
        }

        self.featured = try await self.apiClient.fetchFeatured().threads
    }

    @MainActor
    func isThreadBookmarked(thread: MusicThreadAPI.Thread) async -> Bool {
        guard await self.apiClient.isAuthenticated() else {
            return false
        }

        return self.bookmarks.contains(where: { $0.key == thread.key })
    }

    @MainActor
    func isThreadOwn(thread: MusicThreadAPI.Thread) -> Bool {
        return self.threads.contains(where: { $0.key == thread.key })
    }

}
