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
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    DDGAnnotation(location: location, number: viewModel.checkedInProfiles[location.id, default: 0])
                        .onTapGesture {
                            // track what the user tabs
                            locationManager.selectedLocation = location
                            viewModel.isShowingDetailView = true
                        }
                }
            }
            .accentColor(.grubRed) // MARK: deprecated in future iOS versions
            .ignoresSafeArea(edges: .top)

            VStack {
                LogoView(frameWidth: 125)
                    .shadow(radius: 10)
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.isShowingDetailView) {
            NavigationView {
                // closure the returns the content of the sheet
                // force unwrap? -> it is safe because onTapGesture a location is assigned to that property
                LocationDetailView(viewModel: LocationDetailViewModel(location: locationManager.selectedLocation!))
                    .toolbar { Button("Dismiss") { viewModel.isShowingDetailView = false }
                        .accentColor(.brandPrimary) // or use
//                        .foregroundColor(.brandPrimary)
                    }
            }
        }
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(viewModel.alertItem?.message ?? "")
                  }
        .onAppear {
            // pass in a reference to the locationManager (as the view model is a class)!
            if locationManager.locations.isEmpty { viewModel.getLocations(for: locationManager) }
            viewModel.getCheckedInCounts()
        }
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}
