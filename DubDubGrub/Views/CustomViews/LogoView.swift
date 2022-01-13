//
//  LogoView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 12.01.22.
//

import SwiftUI

struct LogoView: View {

    var frameWidth: CGFloat

    var body: some View {
        Image("ddg-map-logo")
            .resizable()
            .scaledToFit()
            .frame(width: frameWidth)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(frameWidth: 250)
    }
}
