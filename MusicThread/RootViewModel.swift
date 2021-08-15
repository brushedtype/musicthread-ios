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

@MainActor
final class RootViewModel: ObservableObject {

    let client: ClientCredentials
    let keychain: Keychain
    let apiClient: API

    private var fetchThreadsTask: Task<Void, Never>?
    private var fetchBookmarksTask: Task<Void, Never>?
    private var fetchFeaturedTask: Task<Void, Never>?

    @Published var threads: [MusicThreadAPI.Thread] = []
    @Published var bookmarks: [MusicThreadAPI.Thread] = []
    @Published var featured: [MusicThreadAPI.Thread] = []


    init(client: ClientCredentials, keychain: Keychain) {
        self.client = client
        self.apiClient = API(client: client, keychain: keychain)
        self.keychain = keychain
    }

    func setAuth(tokenResponse: TokenResponse) async throws {
        try await self.apiClient.setAuth(tokenResponse)
        await self.fetchInitialContent()
    }

    func fetchInitialContent() async {
        await self.fetchThreads()
        await self.fetchBookmarks()
        await self.fetchFeatured()
    }

    func fetchThreads() async {
        if let task = self.fetchThreadsTask {
            return await task.value
        }

        let task = Task {
            guard await self.apiClient.isAuthenticated() else {
                return
            }

            guard let response = try? await self.apiClient.fetchThreads() else {
                return
            }

            self.threads = response.threads
        }

        self.fetchThreadsTask = task
        defer {
            self.fetchThreadsTask = nil
        }

        return await task.value
    }

    func fetchBookmarks() async {
        if let task = self.fetchBookmarksTask {
            return await task.value
        }

        let task = Task {
            guard await self.apiClient.isAuthenticated() else {
                return
            }

            guard let response = try? await self.apiClient.fetchBookmarks() else {
                return
            }

            self.bookmarks = response.threads
        }

        self.fetchBookmarksTask = task
        defer {
            self.fetchBookmarksTask = nil
        }

        return await task.value
    }

    func fetchFeatured() async {
        if let task = self.fetchFeaturedTask {
            return await task.value
        }

        let task = Task {
            guard await self.apiClient.isAuthenticated() else {
                return
            }

            guard let response = try? await self.apiClient.fetchFeatured() else {
                return
            }

            self.featured = response.threads
        }

        self.fetchFeaturedTask = task
        defer {
            self.fetchFeaturedTask = nil
        }

        return await task.value
    }

}

extension RootViewModel {

    func isThreadBookmarked(thread: MusicThreadAPI.Thread) -> Bool {
        return self.bookmarks.contains(where: { $0.key == thread.key })
    }

    func isThreadOwn(thread: MusicThreadAPI.Thread) -> Bool {
        return self.threads.contains(where: { $0.key == thread.key })
    }

}
