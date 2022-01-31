//
//  MapBallon.swift
//  DubDubGrub
//
//  Created by Simon Berner on 31.01.22.
//

import SwiftUI

struct MapBallon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY)) // starting point
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                      control: CGPoint(x: rect.minX, y: rect.minY)) // control point is in the upper left corner
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control: CGPoint(x: rect.maxX, y: rect.minY)) // control point is in the upper right corner

        return path
    }


}

struct MapBallon_Previews: PreviewProvider {
    static var previews: some View {
        MapBallon()
            .frame(width: 300, height: 220)
            .foregroundColor(.brandPrimary)
    }
}
