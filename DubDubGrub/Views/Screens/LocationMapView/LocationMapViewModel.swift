//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 05.01.22.
//

import MapKit
import OSLog

// ObservableObject: others can observe instances of this class
final class LocationMapViewModel: ObservableObject {

    @Published var showAlert = false
    // set Apple WWDC Convention Center as location
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                                      longitude: -121.891054),
                                                       span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                              longitudeDelta: 0.01))
    @Published var locations: [DDGLocation] = []

    func getLocations() {
        CloudKitManager.getLocations { [self] result in
            switch result {
                // getting back an array of locations
            case .success(let locations):
                self.locations = locations
                Logger.locationMapViewModel.info("\(locations)")
            case .failure(let error):
                showAlert = true
                Logger.locationMapViewModel.error("\(error.localizedDescription)")
            }
        }
    }


}
