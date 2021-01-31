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


    var body: some View {
        NavigationView {
            List(self.threads, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, apiClient: self.apiClient)) {
                    ThreadListItemView(thread: thread)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing: Button(action: { debugPrint("new thread pressed") }, label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .accessibility(hint: Text("New Thread"))
            }))
            .navigationTitle("Threads")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem {
            Image(systemName: "rectangle.grid.1x2.fill")
            Text("Threads")
        }
    }

}
