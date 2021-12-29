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
}
