//
//  ThreadLinkItemView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI
import Kingfisher
import MusicThreadAPI

struct ThreadLinkItemView: View {

    let link: MusicThreadAPI.Link

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
