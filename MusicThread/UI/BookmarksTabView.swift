//
//  BookmarksTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI
import MusicThreadAPI

struct BookmarksTabView: View {

    @ObservedObject var viewModel: RootViewModel


    var body: some View {
        NavigationView {
            List(self.viewModel.bookmarks, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, viewModel: self.viewModel)) {
                    ThreadListItemView(thread: thread)
                        .onDisappear {
                            Task.detached(priority: .userInitiated) {
                                try await self.viewModel.fetchBookmarks()
                            }
                        }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                try? await self.viewModel.fetchBookmarks()
            }
        }
        .tabItem {
            Image(systemName: "bookmark.fill")
            Text("Bookmarks")
        }
    }

}

extension ThreadView {

    @MainActor
    init(thread: MusicThreadAPI.Thread, viewModel: RootViewModel) {
        self.init(
            thread: thread,
            isOwnThread: viewModel.isThreadOwn(thread: thread),
            bookmarkState: { viewModel.isThreadBookmarked(thread: thread) },
            reloadBookmarks: viewModel.fetchBookmarks,
            apiClient: viewModel.apiClient
        )
    }

}
