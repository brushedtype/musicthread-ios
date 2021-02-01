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
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing: self.navigationItems)
            .navigationTitle("Threads")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: self.$isPresentingNewThreadView, content: {
            NavigationView {
                NewThreadView(isSubmittingThread: self.$isSubmittingNewThread) { threadTitle in
                    self.createThread(title: threadTitle)
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

    func createThread(title: String) {
        guard self.isSubmittingNewThread == false else {
            return
        }

        self.isSubmittingNewThread = true

        self.viewModel.apiClient.createThread(title: title) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(_):
                    self.viewModel.fetchThreads()
                    self.isPresentingNewThreadView = false
                }

                self.isSubmittingNewThread = false
            }
        }
    }

}
