//
//  FeaturedTabView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI

struct FeaturedTabView: View {

    @ObservedObject var viewModel: RootViewModel


    var body: some View {
        NavigationView {
            List(self.viewModel.featured, id: \.key) { thread in
                NavigationLink(destination: ThreadView(thread: thread, viewModel: self.viewModel)) {
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
