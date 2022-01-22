//
//  ProfileModalView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.01.22.
//

import SwiftUI

struct ProfileModalView: View {

    @Binding var isShowingProfileModalView: Bool

    var profile: DDGProfile

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.9)
                .ignoresSafeArea()

            GroupBox {
                VStack(alignment: .center, spacing: 5) {
                    HStack {
                        Text(profile.firstName)
                            .bold()
                        Text(profile.lastName)
                            .bold()
                    }
                    Text(profile.companyName)
                        .foregroundColor(.secondary)
                }
                .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))
                Text(profile.bio)
                    .lineLimit(3)
                    .padding()
            }
            .background(Color(.systemBackground))
            .padding()
            .cornerRadius(80)
            .overlay(DismissButton(isShowingView: $isShowingProfileModalView), alignment: .topTrailing)

            AvatarView(image: PlaceholderImage.avatar, size: 120)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                .offset(y: -120)
        }
    }
}

struct ProfileModalView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileModalView(isShowingProfileModalView: .constant(true), profile: DDGProfile(record: MockData.profile) )
    }
}
