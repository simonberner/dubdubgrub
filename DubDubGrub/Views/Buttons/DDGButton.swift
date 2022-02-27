//
//  DDGButton.swift
//  DubDubGrub
//
//  Created by Simon Berner on 28.12.21.
//

import SwiftUI

struct DDGButton: View {

    var title: String
    var color: Color = .brandPrimary

    var body: some View {
        Text(title)
            .bold()
            .frame(width: 280, height: 44)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct DDGButton_Previews: PreviewProvider {
    static var previews: some View {
        DDGButton(title: "Test Button")
    }
}
