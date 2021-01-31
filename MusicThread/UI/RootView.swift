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
            ThreadsTabView(apiClient: self.viewModel.apiClient, threads: self.viewModel.threads)

            BookmarksTabView(apiClient: self.viewModel.apiClient, bookmarks: self.viewModel.bookmarks)

            FeaturedTabView(apiClient: self.viewModel.apiClient, featured: self.viewModel.featured)
        }
    }

}
