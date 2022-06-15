//
//  ThreadView.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI
import MusicThreadAPI

struct ThreadView: View {

    let thread: MusicThreadAPI.Thread
    let isOwnThread: Bool
    let bookmarkState: () -> Bool
    let reloadBookmarks: () async throws -> Void

    @State var isBookmarked = false
    @State var isFetchingLinks = false
    @State var links: [MusicThreadAPI.Link] = []

    @State var isPresentingNewLinkView = false
    @State var isSubmittingLink = false

    let apiClient: API


    var body: some View {
        List {
            Section(header: ThreadHeaderView(thread: self.thread).textCase(nil)) {
                if self.thread.isPrivate && self.isOwnThread == false {
                    VStack {
                        Text("This thread is private.")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                } else if self.isFetchingLinks && self.links.isEmpty {
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
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
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
        .listStyle(InsetGroupedListStyle())
        .navigationBarItems(trailing: self.navigationBarItems)
        .onAppear(perform: {
            if self.thread.isPrivate && self.isOwnThread == false {
                return
            }

            self.isBookmarked = self.bookmarkState()

            Task.detached(priority: .userInitiated) {
                await self.reloadLinks()
            }
        })
        .refreshable {
            await self.reloadLinks()
        }
        .sheet(isPresented: self.$isPresentingNewLinkView, content: {
            NavigationView {
                NewLinkView(isSubmitting: self.$isSubmittingLink) { (linkURL) in
                    Task.detached(priority: .userInitiated) {
                        await self.submitLink(linkURL)
                    }
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
                    let newState = !self.isBookmarked
                    self.isBookmarked = newState

                    Task.detached(priority: .userInitiated) {
                        await self.updateBookmark(newState: newState)
                    }
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


    private func reloadLinks() async {
        guard self.isFetchingLinks == false else {
            return
        }

        self.isFetchingLinks = true

        do {
            self.links = try await self.apiClient.fetchThread(key: self.thread.key).links
        } catch {
            debugPrint(error)
        }

        self.isFetchingLinks = false
    }

    private func submitLink(_ linkURL: String) async {
        guard self.isSubmittingLink == false else {
            return
        }

        self.isSubmittingLink = true

        do {
            let _ = try await self.apiClient.submitLink(threadKey: self.thread.key, description: "", linkURL: linkURL)
            await self.reloadLinks()

            self.isPresentingNewLinkView = false
        } catch {
            debugPrint(error)
        }

        self.isSubmittingLink = false
    }

    private func updateBookmark(newState: Bool) async {
        do {
            self.isBookmarked = try await self.apiClient.updateBookmark(threadKey: self.thread.key, isBookmarked: newState).isBookmarked
//            try await self.reloadBookmarks()
        } catch {
            debugPrint(error)
        }
    }

}
