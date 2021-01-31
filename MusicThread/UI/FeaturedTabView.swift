//
//  FeaturedTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI

struct FeaturedTabView: View {

    let apiClient: API
    let featured: [Thread]

    var body: some View {
        NavigationView {
            List(self.featured, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, apiClient: self.apiClient)) {
                    ThreadListItemView(thread: thread)
                }
            }
            .navigationTitle("Featured")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem {
            Image(systemName: "star.circle.fill")
            Text("Featured")
        }
    }

}
