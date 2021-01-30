//
//  ThreadList.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI

class ThreadListViewModel: ObservableObject {

    let apiClient = API(baseURL: URL(string: "https://musicthread.app/api")!)

    @Published var threads: [Thread] = []
    @Published var bookmarks: [Thread] = []


    func setAuth(tokenResponse: TokenResponse) {
        self.apiClient.setTokenStore(TokenStore(authBaseURL: "https://musicthread.app/oauth", tokenResponse: tokenResponse))

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
        }
    }

}
