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

    var body: some View {
        VStack(spacing: 16.0) {
            VStack(spacing: 6.0) {
                Text(verbatim: self.thread.title)
                    .font(.title)
                    .multilineTextAlignment(.center)

                Text(verbatim: self.thread.author.name)
                    .font(.subheadline)
            }

            VStack {
                Text(verbatim: self.thread.description)
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .padding(.top, 16)
        .navigationBarItems(trailing: Link("Open", destination: self.thread.pageURL))
    }

}
