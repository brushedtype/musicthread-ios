//
//  BookmarksTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI

struct BookmarksTabView: View {

    let apiClient: API
    let bookmarks: [Thread]


    var body: some View {
        NavigationView {
            List(self.bookmarks, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, apiClient: self.apiClient)) {
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
