//
//  CustomModifiers.swift
//  DubDubGrub
//
//  Created by Simon Berner on 28.12.21.
//

import SwiftUI

// Custom modifier
struct ProfileViewText: ViewModifier {
    func body(content: Content) -> some View {
        content
        .font(.system(size: 32, weight: .bold))
        .lineLimit(2)
        .minimumScaleFactor(0.75)
    }
}
