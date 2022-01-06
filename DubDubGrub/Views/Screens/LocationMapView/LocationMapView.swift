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

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region).ignoresSafeArea(edges: .top)

            VStack {
                LogoView().shadow(radius: 10)
                Spacer()
            }
        }
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(viewModel.alertItem?.message ?? "")
                  }
        // tip: put the call in the view models init
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
