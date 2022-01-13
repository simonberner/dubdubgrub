//
//  DismissButton.swift
//  DubDubGrub
//
//  Created by Simon Berner on 13.01.22.
//

import SwiftUI

struct DismissButton: View {
    @Binding var isShowingDetail: Bool

    var body: some View {
        Button {
            isShowingDetail = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.brandPrimary)
                .imageScale(.large)
                .frame(width: 44, height: 44) // trick: adding an invisible bigger touch target
        }
    }
}

struct DismissButton_Previews: PreviewProvider {
    static var previews: some View {
        DismissButton(isShowingDetail: .constant(true))
    }
}
