//
//  LocationListCell.swift
//  DubDubGrub
//
//  Created by Simon Berner on 21.12.21.
//

import SwiftUI

struct LocationListCell: View {

    var location: DDGLocation

    var body: some View {
        HStack {
            Image(uiImage: location.createSquareAsset())
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
                HStack {
                    ForEach(0..<4) { item in
                        AvatarView(size: 35)
                    }
                }
            }
            .padding(.leading)

        }
    }
}

struct LocationListCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationListCell(location: DDGLocation(record: MockData.location))
    }
}
