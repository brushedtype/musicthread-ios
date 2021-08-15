//
//  FeaturedTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI
import MusicThreadAPI

struct FeaturedTabView: View {

    @ObservedObject var viewModel: RootViewModel


    var body: some View {
        NavigationView {
            List(self.viewModel.featured, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, viewModel: self.viewModel)) {
                    ThreadListItemView(thread: thread)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Featured")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await self.viewModel.fetchFeatured()
            }
            .onAppear {
                Task.detached(priority: .userInitiated) {
                    await self.viewModel.fetchFeatured()
                }
            }
        }
        .tabItem {
            Image(systemName: "star.circle.fill")
            Text("Featured")
        }
    }

}
