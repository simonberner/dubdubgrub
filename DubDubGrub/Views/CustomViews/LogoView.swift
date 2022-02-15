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
        // decorative: voice over does not read out the image label
        Image(decorative: "ddg-map-logo")
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
