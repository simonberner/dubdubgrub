//
//  LocationMapView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import CoreLocationUI
import SwiftUI
import MapKit
import OSLog

struct LocationMapView: View {

    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = LocationMapViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .top) {

            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: locationManager.locations) { location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    DDGAnnotation(location: location, number: viewModel.checkedInProfiles[location.id, default: 0])
                        .accessibilityLabel(Text(viewModel.createVoiceOverSummary(for: location)))
                        .onTapGesture {
                            // track what the user tabs
                            locationManager.selectedLocation = location
                            viewModel.isShowingDetailView = true
                        }
                }
            }
//            .tint(.grubRed) MARK: seems not to work yet!
            .accentColor(.grubRed)
            .ignoresSafeArea(edges: .top)

            LogoView(frameWidth: 125).shadow(radius: 10)


        }
        .sheet(isPresented: $viewModel.isShowingDetailView) {
            NavigationView {
                // closure the returns the content of the sheet
                // force unwrap? -> it is safe because onTapGesture a location is assigned to that property
                viewModel.createLocationDetailView(for: locationManager.selectedLocation!, in: dynamicTypeSize)
                    .toolbar { Button("Dismiss") { viewModel.isShowingDetailView = false }
                    }
            }
        }
        .overlay(alignment: .bottomLeading) {
            LocationButton(.currentLocation) {
                viewModel.requestAllowOnceLocationPermission()
            }
            .foregroundColor(.white)
            .symbolVariant(.fill)
            .tint(.grubRed)
            .labelStyle(.iconOnly)
            .clipShape(Circle())
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 0))
        }
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: { Text(viewModel.alertItem?.message ?? "") }
        .task {
            // pass in a reference to the locationManager (as the view model is a class)!
            if locationManager.locations.isEmpty { viewModel.getLocations(for: locationManager) }
            viewModel.getCheckedInCounts()
        }
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView().environmentObject(LocationManager())
    }
}
