//
//  ThreadListItemView.swift
//  MusicThread Auth
//
//  Created by Edward Wellbrook on 30/01/2021.
//

import Foundation
import SwiftUI

struct ThreadListItemView: View {

    let thread: Thread

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(verbatim: self.thread.title)

            Text(verbatim: self.thread.author.name)
                .font(.caption)
                .opacity(0.8)
        }
        .padding(.vertical, 4.0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}
