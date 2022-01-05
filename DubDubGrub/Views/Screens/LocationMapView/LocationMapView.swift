//
//  LocationMapView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI
import MapKit
import OSLog

struct LocationMapView: View {

    @StateObject private var viewModel = LocationMapViewModel()

    init() {
        viewModel.getLocations()
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region).ignoresSafeArea(edges: .top)

            VStack {
                LogoView().shadow(radius: 10)
                Spacer()
            }
        }
        // experimenting with the new iOS15 view modifier instead of using the AlertItem
        .alert(Text("Locations Error"), isPresented: $viewModel.showAlert) {
                      Button("Ok", role: .cancel) { }
                  } message: {
                      Text("Unable to retrieve locations at this time. \n Please try again.")
                  }
        // tip: get the locations either here or above in the init
//        .onAppear {
//            viewModel.getLocations()
//        }
    }
}

struct LogoView: View {
    var body: some View {
        Image("ddg-map-logo")
            .resizable()
            .scaledToFit()
            .frame(height: 70)
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}
