//
//  AvatarView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 21.12.21.
//

import SwiftUI

struct AvatarView: View {

    var image: UIImage
    var size: CGFloat

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(image: PlaceholderImage.avatar, size: 35)
    }
}
