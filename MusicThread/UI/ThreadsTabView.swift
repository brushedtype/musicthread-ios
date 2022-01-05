//
//  ThreadsTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI

struct ThreadsTabView: View {

    @ObservedObject var viewModel: RootViewModel

    @State var isPresentingNewThreadView = false
    @State var isSubmittingNewThread = false


    var body: some View {
        NavigationView {
            List(self.viewModel.threads, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, viewModel: self.viewModel)) {
                    ThreadListItemView(thread: thread)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: self.navigationItems)
            .navigationTitle("Threads")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await self.viewModel.fetchThreads()
            }
            .onAppear {
                Task.detached(priority: .userInitiated) {
                    await self.viewModel.fetchThreads()
                }
            }
        }
        .sheet(isPresented: self.$isPresentingNewThreadView, content: {
            NavigationView {
                NewThreadView(isSubmittingThread: self.$isSubmittingNewThread) { threadTitle, isPrivate in
                    Task.detached(priority: .userInitiated) {
                        try await self.createThread(title: threadTitle, isPrivate: isPrivate)
                    }
                }
                .navigationTitle("Create New Thread")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
        .tabItem {
            Image(systemName: "rectangle.grid.1x2.fill")
            Text("Threads")
        }
    }

    var navigationItems: some View {
        Button(action: {
            self.isPresentingNewThreadView = true
        }, label: {
            Image(systemName: "plus")
                .imageScale(.large)
                .accessibility(hint: Text("New Thread"))
        })
    }

    func createThread(title: String, isPrivate: Bool) async throws {
        guard self.isSubmittingNewThread == false else {
            return
        }

        self.isSubmittingNewThread = true

        do {
            let _ = try await self.viewModel.apiClient.createThread(title: title, description: nil, tags: [], isPrivate: isPrivate)
            await self.viewModel.fetchThreads()

            self.isPresentingNewThreadView = false
        } catch {
            debugPrint(error)
        }

        self.isSubmittingNewThread = false
    }

}
