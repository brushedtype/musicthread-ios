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

    let submitAction: (String) -> Void


    var body: some View {
        Form {
            TextField("URL to song or album", text: self.$urlString)
        }
        .navigationBarItems(trailing:
            Button("Submit", action: {
                self.submitAction(self.urlString)
            }).disabled(self.urlString.isEmpty)
        )
        .listStyle(PlainListStyle())
        .frame(maxWidth: .infinity)
    }

}
