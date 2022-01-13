//
//  OnboardView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 12.01.22.
//

import SwiftUI

struct OnboardView: View {
    @Binding var isShowingDetail: Bool

    var body: some View {
        // GeometryReader: container view that defines its own size from
        // the parent (here the device screen) and gives it to its content
        // (children) via a GeometryProxy
        GeometryReader { proxy in
            VStack {
                Spacer()
                LogoView(frameWidth: 250)
                    .padding(.bottom)
                OnboardInfoView(image: "building.2.crop.circle",
                            title: Text("Restaurant Locations"),
                            description: Text("Find places to dine around the convention center"))
                OnboardInfoView(image: "checkmark.circle",
                            title: Text("Check In"),
                            description: Text("Let other iOS Devs know where you are"))
                OnboardInfoView(image: "person.2.circle",
                            title: Text("Find Friends"),
                            description: Text("See where other iOS Devs are and join the party"))
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .cornerRadius(20)
            .background(Color(.systemBackground))
            .overlay(DismissButton(isShowingDetail: $isShowingDetail), alignment: .topTrailing)
        }
        .padding()

    }
}

struct OnboardInfoView: View {

    var image: String
    var title: Text
    var description: Text

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: image)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.brandPrimary)
            VStack(alignment: .leading) {
                title.bold()
                description
                    .foregroundColor(.secondary)
                    .fontWeight(.thin)
                    .lineLimit(2)
            }
        }
        .frame(width: 300, alignment: .leading)
        .padding()
    }
}

struct DismissButton: View {
    @Binding var isShowingDetail: Bool

    var body: some View {
        Button {
            isShowingDetail = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.brandPrimary)
                .imageScale(.large)
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(isShowingDetail: .constant(true))
    }
}
