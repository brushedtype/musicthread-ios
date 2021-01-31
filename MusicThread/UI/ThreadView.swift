//
//  ThreadView.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI

struct ThreadView: View {

    let thread: Thread
    let isOwnThread: Bool
    let bookmarkState: () -> Bool
    let reloadBookmarks: () -> Void

    @State var isBookmarked: Bool = false
    @State var isFetchingLinks = true
    @State var links: [Link] = []

    let apiClient: API


    var body: some View {
        List {
            Section(header: ThreadHeaderView(thread: self.thread).textCase(nil)) {
                if self.isFetchingLinks {
                    VStack {
                        HStack(spacing: 16) {
                            ProgressView()
                            Text("Loading links...")
                        }
                        .foregroundColor(Color(.placeholderText))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                } else if self.links.isEmpty {
                    VStack {
                        Text("\(self.thread.author.name) hasn't posted any links yet...")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                } else {
                    ForEach(self.links, id: \.key) { link in
                        ThreadLinkItemView(link: link)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarItems(trailing: HStack(spacing: 20) {
            if self.isOwnThread == false {
                Button(action: {
                    let isBookmarked = self.isBookmarked

                    self.apiClient.updateBookmark(threadKey: self.thread.key, isBookmarked: !isBookmarked) { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(let error):
                                debugPrint(error)
                            case .success(let response):
                                self.isBookmarked = response.isBookmarked
                            }
                            self.reloadBookmarks()
                        }
                    }
                }, label: {
                    Image(systemName: self.isBookmarked ? "bookmark.fill" : "bookmark")
                        .imageScale(.large)
                })
            }

            SwiftUI.Link(destination: self.thread.pageURL, label: {
                Image(systemName: "safari")
                    .imageScale(.large)
                    .accessibility(hint: Text("Open in Safari"))
            })
        })
        .onAppear(perform: {
            self.isBookmarked = self.bookmarkState()

            self.apiClient.fetchThread(key: self.thread.key) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        debugPrint(error)
                    case .success(let threadResponse):
                        self.links = threadResponse.links
                        self.isFetchingLinks = false
                    }
                }
            }
        })
    }

}
