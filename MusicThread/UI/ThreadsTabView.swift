//
//  ThreadsTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI

struct ThreadsTabView: View {

    let apiClient: API
    let threads: [Thread]

    let reloadThreads: () -> Void

    @State var isPresentingNewThreadView = false


    var body: some View {
        NavigationView {
            List(self.threads, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, apiClient: self.apiClient)) {
                    ThreadListItemView(thread: thread)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing: Button(action: {
                self.isPresentingNewThreadView = true
            }, label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .accessibility(hint: Text("New Thread"))
            }))
            .navigationTitle("Threads")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: self.$isPresentingNewThreadView, content: {
            NavigationView {
                NewThreadView(submitAction: { threadTitle in
                    self.apiClient.createThread(title: threadTitle) { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(let error):
                                debugPrint(error)
                            case .success(let response):
                                debugPrint(response.thread)
                                self.reloadThreads()
                                self.isPresentingNewThreadView = false
                            }
                        }
                    }
                })
                .navigationTitle("Create New Thread")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
        .tabItem {
            Image(systemName: "rectangle.grid.1x2.fill")
            Text("Threads")
        }
    }

}
