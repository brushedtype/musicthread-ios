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

    @State var isBookmarked = false
    @State var isFetchingLinks = false
    @State var links: [Link] = []

    @State var isPresentingNewLinkView = false
    @State var isSubmittingLink = false

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
        .navigationBarItems(trailing: self.navigationBarItems)
        .onAppear(perform: {
            self.isBookmarked = self.bookmarkState()
            self.reloadLinks()
        })
        .sheet(isPresented: self.$isPresentingNewLinkView, content: {
            NavigationView {
                NewLinkView(isSubmitting: self.$isSubmittingLink) { (linkURL) in
                    self.submitLink(linkURL)
                }
                .navigationTitle("Add Music")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
    }

    var navigationBarItems: some View {
        HStack(spacing: 20) {
            if self.isOwnThread == false {
                Button(action: {
                    self.updateBookmark(newState: !self.isBookmarked)
                }, label: {
                    Image(systemName: self.isBookmarked ? "bookmark.fill" : "bookmark")
                        .imageScale(.large)
                })
            } else {
                Button(action: {
                    self.isPresentingNewLinkView = true
                }, label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                })
            }

            SwiftUI.Link(destination: self.thread.pageURL, label: {
                Image(systemName: "safari")
                    .imageScale(.large)
                    .accessibility(hint: Text("Open in Safari"))
            })
        }
    }


    private func reloadLinks() {
        guard self.isFetchingLinks == false else {
            return
        }

        self.isFetchingLinks = true

        self.apiClient.fetchThread(key: self.thread.key) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(let threadResponse):
                    self.links = threadResponse.links
                }

                self.isFetchingLinks = false
            }
        }
    }

    private func submitLink(_ linkURL: String) {
        guard self.isSubmittingLink == false else {
            return
        }

        self.isSubmittingLink = true

        self.apiClient.submitLink(threadKey: self.thread.key, linkURL: linkURL) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    debugPrint(err)
                case .success(_):
                    self.reloadLinks()
                    self.isPresentingNewLinkView = false
                }

                self.isSubmittingLink = false
            }
        }
    }

    private func updateBookmark(newState: Bool) {
        self.apiClient.updateBookmark(threadKey: self.thread.key, isBookmarked: newState) { (result) in
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
    }

}
