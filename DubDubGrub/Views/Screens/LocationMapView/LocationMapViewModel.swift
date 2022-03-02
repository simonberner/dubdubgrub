//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 05.01.22.
//

import MapKit
import OSLog
import CloudKit
import SwiftUI

// extra safety: encapsulate the view model into an extension so that no one else can access it
extension LocationMapView {

    // ObservableObject: others can observe instances of this class
    final class LocationMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

        @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
        @Published var isShowingDetailView = false
        @Published var showAlert = false
        @Published var alertItem: AlertItem?

        // set Apple WWDC Convention Center as location
        @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                                  longitude: -121.891054),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                          longitudeDelta: 0.01))

        var deviceLocationAManager = CLLocationManager()

        override init() {
            super.init()
            deviceLocationAManager.delegate = self
        }

        func requestAllowOnceLocationPermission() {
            deviceLocationAManager.requestLocation()
        }

        // the .requestLocation above triggers this
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            guard let currentLocation = locations.last else { return }

            withAnimation {
                region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            showAlert = true
            alertItem = AlertContext.didFailOnLocationManager
            Logger.locationMapViewModel.error("locationManager failed: \(error.localizedDescription)")
        }

        /*
         The getLocations() call can be put here. This way you can omit the .onAppear in the View.
         It will get fired when the ViewModel is initialized, which happens each time the LocationMapView redraws.
         */
        //    init() {
        //        getLocations()
        //    }

        // @MainActor: Anything in this method will be rerouted to the main (UI) queue/thread
        @MainActor func getLocations(for locationManager: LocationManager) {
            CloudKitManager.shared.getLocations { [self] result in
                Task {
                    switch result {
                        // getting back an array of locations
                    case .success(let locations):
                        locationManager.locations = locations
                        Logger.locationMapViewModel.info("\(locations)")
                    case .failure(let error):
                        alertItem = AlertContext.unableToGetLocations
                        showAlert = true
                        Logger.locationMapViewModel.error("getLocations: \(error.localizedDescription)")
                    }
                }
            }
        }

        func getCheckedInCounts() {
            CloudKitManager.shared.getCheckedInProfilesCount { result in
                DispatchQueue.main.async { [self] in
                    switch result {
                    case .success(let checkedInProfiles):
                        self.checkedInProfiles = checkedInProfiles
                    case .failure(_):
                        alertItem = AlertContext.checkedInCount
                        break
                    }
                }
            }
        }

        func createVoiceOverSummary(for location: DDGLocation) -> String {
            let count = checkedInProfiles[location.id, default: 0]
            let personPlurality = count == 1 ? "person" : "people"

            return " Map Pin \(location.name) \(count) \(personPlurality) checked in."
        }

        @ViewBuilder func createLocationDetailView(for location: DDGLocation, in dynamicTypeSize: DynamicTypeSize) -> some View {
            if dynamicTypeSize >= .accessibility3 {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
            } else {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location))
            }
        }
    }
}

