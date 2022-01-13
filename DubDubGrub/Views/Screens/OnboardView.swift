//
//  OnboardView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 12.01.22.
//

import SwiftUI

struct OnboardView: View {

    @Binding var isShowingOnboardView: Bool

    var body: some View {
        // GeometryReader: container view that defines its own size from
        // the parent (here the device screen) and gives it to its content
        // (children) via a GeometryProxy
        GeometryReader { proxy in
            VStack {
                LogoView(frameWidth: proxy.size.width)
                    .padding(.bottom)
                VStack(alignment: .leading, spacing: 34) {
                    OnboardInfoView(imageName: "building.2.crop.circle",
                                title: "Restaurant Locations",
                                description: "Find places to dine around the convention center")
                    OnboardInfoView(imageName: "checkmark.circle",
                                title: "Check In",
                                description: "Let other iOS Devs know where you are")
                    OnboardInfoView(imageName: "person.2.circle",
                                title: "Find Friends",
                                description: "See where other iOS Devs are and join the party")
                }
                .padding(.horizontal, 40)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .cornerRadius(20)
            .background(Color(.systemBackground))
            .overlay(DismissButton(isShowingOnboardView: $isShowingOnboardView), alignment: .topTrailing)
        }
    }
}

struct OnboardInfoView: View {

    var imageName: String
    var title: String
    var description: String

    var body: some View {
        HStack(spacing: 26) {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.brandPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).bold()
                Text(description)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(isShowingOnboardView: .constant(true))
    }
}
