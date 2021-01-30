//
//  ThreadList.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI
import KeychainAccess

class ThreadListViewModel: ObservableObject {

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

}

struct ThreadListView: View {

    @ObservedObject var viewModel: ThreadListViewModel


    var body: some View {
        TabView {
            NavigationView {
                List(self.viewModel.threads, id: \.key) { thread in
                    NavigationLink(destination: ThreadView(thread: thread, apiClient: self.viewModel.apiClient)) {
                        ThreadListItemView(thread: thread)
                    }
                }
                .navigationTitle("Threads")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "rectangle.grid.1x2.fill")
                Text("Threads")
            }

            NavigationView {
                List(self.viewModel.bookmarks, id: \.key) { thread in
                    NavigationLink(destination: ThreadView(thread: thread, apiClient: self.viewModel.apiClient)) {
                        ThreadListItemView(thread: thread)
                    }
                }
                .navigationTitle("Bookmarks")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "bookmark.fill")
                Text("Bookmarks")
            }

            NavigationView {
                List(self.viewModel.featured, id: \.key) { thread in
                    NavigationLink(destination: ThreadView(thread: thread, apiClient: self.viewModel.apiClient)) {
                        ThreadListItemView(thread: thread)
                    }
                }
                .navigationTitle("Featured")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "star.circle.fill")
                Text("Featured")
            }
        }
    }

}
