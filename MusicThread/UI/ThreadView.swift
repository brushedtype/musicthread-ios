//
//  ThreadView.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI
import Kingfisher

struct ThreadHeaderView: View {

    let thread: Thread

    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 6.0) {
                Text(verbatim: self.thread.title)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)

                Text(verbatim: self.thread.author.name)
                    .font(.subheadline)
            }

            if self.thread.description.isEmpty == false {
                VStack {
                    Text(verbatim: self.thread.description)
                        .font(.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.vertical, 16)
    }

}

struct ThreadLinkItemView: View {

    let link: Link

    var body: some View {
        SwiftUI.Link(destination: self.link.pageURL, label: {
            HStack(alignment: .top, spacing: 8) {
                KFImage(self.link.thumbnailURL)
                    .appendProcessor(ResizingImageProcessor(referenceSize: CGSize(width: 38, height: 38), mode: .aspectFill))
                    .scaleFactor(UIScreen.main.scale)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 38, height: 38)
                    .background(Color(.placeholderText))
                    .cornerRadius(3)

                VStack(alignment: .leading, spacing: 4.0) {
                    Text(verbatim: self.link.title)

                    Text(verbatim: self.link.artist)
                        .font(.caption)
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 4.0)
            .frame(maxWidth: .infinity, alignment: .leading)
        })
        .foregroundColor(Color(.label))
    }

}

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
                } else {
                    ForEach(self.links, id: \.key) { link in
                        ThreadLinkItemView(link: link)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarItems(trailing: SwiftUI.Link("Open", destination: self.thread.pageURL))
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
