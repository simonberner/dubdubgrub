//
//  View+Ext.swift
//  DubDubGrub
//
//  Created by Simon Berner on 28.12.21.
//

import SwiftUI

// Improve the usability of the custom view modifier
extension View {

    func profileNameStyle() -> some View {
        self.modifier(ProfileViewText())
    }

    func playHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func embedInScrollView() -> some View {
        GeometryReader { geometry in
            ScrollView {
                frame(minHeight: geometry.size.height, maxHeight: .infinity)
            }
        }
    }
}
