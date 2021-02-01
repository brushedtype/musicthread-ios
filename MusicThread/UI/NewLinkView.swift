//
//  NewLinkView.swift
//  MusicThread
//
//  Created by Edward Wellbrook on 01/02/2021.
//

import Foundation
import SwiftUI

struct NewLinkView: View {

    @State var urlString: String = ""
    @Binding var isSubmitting: Bool

    let submitAction: (String) -> Void


    var body: some View {
        Form {
            TextField("URL to song or album", text: self.$urlString)
        }
        .navigationBarItems(trailing: self.navigationItems)
        .listStyle(PlainListStyle())
        .frame(maxWidth: .infinity)
    }

    var navigationItems: some View {
        HStack {
            if self.isSubmitting {
                ProgressView()
            } else {
                Button("Submit", action: {
                    self.submitAction(self.urlString)
                }).disabled(self.urlString.isEmpty)
            }
        }
    }

}
