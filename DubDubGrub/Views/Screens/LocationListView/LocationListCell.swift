//
//  LocationListCell.swift
//  DubDubGrub
//
//  Created by Simon Berner on 21.12.21.
//

import SwiftUI

struct LocationListCell: View {

    var location: DDGLocation
    var profiles: [DDGProfile]

    var body: some View {
        HStack {
            Image(uiImage: location.getImage(for: .square))
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(.vertical, 8)

            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    if profiles.isEmpty {
                        Text("Nobody is Checked In here")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.top, 1)
                    } else {
                        HStack {
                            ForEach(profiles.indices, id: \.self) { index in
                                // we only allow 4 profile avatars to be shown
                                if index <= 3 {
                                    AvatarView(image: profiles[index].getImage(for: .avatar), size: 35)
                                    // for more we show the +'' view
                                } else if index == 4 {
                                    AdditionalProfilesView(number: profiles.count - 4)
                                }
                            }
                        }
                    }
            }
            .padding(.leading)
        }
    }
}

struct LocationListCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationListCell(location: DDGLocation(record: MockData.location), profiles: [])
    }
}

struct AdditionalProfilesView: View {

    var number: Int

    var body: some View {
        Text("+ \(number < 100 ? number : 99)") // show a max of +99 even if there are more checked in
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 35, height: 35)
            .foregroundColor(.white)
            .background(Color.brandPrimary)
            .clipShape(Circle())
    }
}
