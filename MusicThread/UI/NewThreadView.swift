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

    @Binding var isSubmittingThread: Bool
    let submitAction: (String) -> Void


    var body: some View {
        Form {
            TextField("Title", text: self.$threadTitle)
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
                    self.submitAction(self.threadTitle)
                }).disabled(self.threadTitle.isEmpty)
            }
        }
    }

}
