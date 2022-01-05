//
//  NewThreadView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 31/01/2021.
//

import Foundation
import SwiftUI

struct NewThreadView: View {

    @State var threadTitle: String = ""
    @State var isPrivate: Bool = false

    @Binding var isSubmittingThread: Bool
    let submitAction: (String, Bool) -> Void


    var body: some View {
        Form {
            Section {
                TextField("Title", text: self.$threadTitle)
            }

            Section {
                Toggle("Private", isOn: self.$isPrivate)
            }
        }
        .navigationBarItems(trailing: self.navigationItems)
        .listStyle(PlainListStyle())
        .frame(maxWidth: .infinity)
    }

    var navigationItems: some View {
        HStack {
            if self.isSubmittingThread {
                ProgressView()
            } else {
                Button("Submit", action: {
                    self.submitAction(self.threadTitle, self.isPrivate)
                }).disabled(self.threadTitle.isEmpty)
            }
        }
    }

}
