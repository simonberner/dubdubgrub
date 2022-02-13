//
//  DDGAnnotation.swift
//  DubDubGrub
//
//  Created by Simon Berner on 31.01.22.
//

import SwiftUI

struct DDGAnnotation: View {

    var location: DDGLocation
    var number: Int

    var body: some View {
        VStack {
            ZStack {
                MapBallon()
                    .frame(width: 100, height: 70)
                    .foregroundColor(.brandPrimary)

                Image(uiImage: location.getImage(for: .square))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .offset(y: -10)

                if number > 0 {
                    Text("\(min(number, 99))")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 26, height: 18)
                        .background(Color.grubRed)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .offset(x: 20, y: -28)
                }
            }

            Text(location.name)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct DDGAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        DDGAnnotation(location: DDGLocation(record: MockData.location), number: 44)
    }
}
