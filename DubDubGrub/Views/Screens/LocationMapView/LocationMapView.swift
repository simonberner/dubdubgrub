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

    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = LocationMapViewModel()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: locationManager.locations) { location in
                MapMarker(coordinate: location.location.coordinate, tint: .brandPrimary)
            }
            .accentColor(.grubRed) // MARK: deprecated in future iOS versions
            .ignoresSafeArea(edges: .top)

            VStack {
                LogoView(frameWidth: 125)
                    .shadow(radius: 10)
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView, onDismiss: viewModel.checkLocationServicesIsEnabled) {
            // closure the returns the content of the sheet
            OnboardView(isShowingOnboardView: $viewModel.isShowingOnboardView)
        }
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(viewModel.alertItem?.message ?? "")
                  }
        .onAppear {
            viewModel.runStartupChecks()
            if locationManager.locations.isEmpty {
                // pass in a reference to the locationManager (as the view model is a class)!
                viewModel.getLocations(for: locationManager)
            }
        }
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}
