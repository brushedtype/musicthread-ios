//
//  ThreadList.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI
import KeychainAccess

struct RootView: View {

    @ObservedObject var viewModel: RootViewModel


    var body: some View {
        TabView {
            ThreadsTabView(viewModel: self.viewModel)
            BookmarksTabView(viewModel: self.viewModel)
            FeaturedTabView(viewModel: self.viewModel)
        }
        .onAppear {
            Task.detached(priority: .userInitiated) {
                await self.viewModel.fetchInitialContent()
            }
        }
    }

}
