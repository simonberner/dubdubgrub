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
        GeometryReader { proxy in
            ZStack {
                Color(.systemBackground)
                    .opacity(0.9)
                    .ignoresSafeArea()

                GroupBox {
                    VStack(alignment: .center, spacing: 5) {
                        Text(profile.firstName + " " + profile.lastName)
                            .bold()
                            .font(.title2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Text(profile.companyName)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .foregroundColor(.secondary)
                            .accessibilityLabel(Text("Works at \(profile.companyName)"))
                    }
                    .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))

                    Text(profile.bio)
                        .lineLimit(3)
                        .padding()
                        .accessibilityLabel(Text("Bio, \(profile.bio)"))
                }
                .frame(width: proxy.size.width - 60)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .overlay(DismissButton(), alignment: .topTrailing)

                AvatarView(image: profile.getImage(for: .avatar), size: 120)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                    .offset(y: -140)
                    .accessibility(hidden: true)
            }
        }
    }
}

struct ProfileModalView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileModalView(isShowingProfileModalView: .constant(true), profile: DDGProfile(record: MockData.profile) )
    }
}
