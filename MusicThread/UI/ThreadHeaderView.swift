//
//  ThreadHeaderView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI
import MusicThreadAPI

struct ThreadHeaderView: View {

    let thread: MusicThreadAPI.Thread

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
        .padding(.bottom, 32)
    }

}
