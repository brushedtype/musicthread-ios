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

    @State var isFetchingLinks = true
    @State var links: [Link] = []

    let apiClient: API


    var body: some View {
        List {
            Section(header: ThreadHeaderView(thread: self.thread).textCase(nil)) {
                if self.isFetchingLinks {
                    HStack(spacing: 16) {
                        ProgressView()
                        Text("Loading links...")
                    }
                    .foregroundColor(Color(.placeholderText))
                    .padding(.vertical, 10)
                } else if self.links.isEmpty {
                    Text("\(self.thread.author.name) hasn't posted any links yet...")
                        .foregroundColor(Color(.placeholderText))
                        .padding(.vertical, 10)
                } else {
                    ForEach(self.links, id: \.key) { link in
                        ThreadLinkItemView(link: link)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarItems(trailing: SwiftUI.Link(destination: self.thread.pageURL, label: {
            Image(systemName: "safari")
                .imageScale(.large)
                .accessibility(hint: Text("Open in Safari"))
        }))
        .onAppear(perform: {
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
