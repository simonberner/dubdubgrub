//
//  ProfileSheetView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.02.22.
//

import SwiftUI

// Accessibility: alternative profile modal view for larger dynamic type sizes
// (Presented as a sheet instead of a small pop up)
// Straight forward design, nothing fancy and cute as we just want to get this view
// working with .accessibilityExtraExtraLarge

struct ProfileSheetView: View {
    
    var profile: DDGProfile
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    AvatarView(image: profile.getImage(for: .avatar), size: 120)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                        .accessibility(hidden: true)

                    GroupBox {
                        VStack(alignment: .center, spacing: 5) {
                            Text(profile.firstName + " " + profile.lastName)
                                .bold()
                                .font(.title2)
                                .minimumScaleFactor(0.9)

                            Text(profile.companyName)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.75)
                                .foregroundColor(.secondary)
                                .accessibilityLabel(Text("Works at \(profile.companyName)"))
                        }
                        .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))

                        Text(profile.bio)
                            .accessibilityLabel(Text("Bio, \(profile.bio)"))
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheetView(profile: DDGProfile(record: MockData.profile))
            .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
    }
}
