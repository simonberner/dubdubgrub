//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 05.01.22.
//

import MapKit
import OSLog
import CloudKit

// ObservableObject: others can observe instances of this class
final class LocationMapViewModel: ObservableObject {

    @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
    @Published var isShowingDetailView = false
    @Published var showAlert = false
    @Published var alertItem: AlertItem?
    
    // set Apple WWDC Convention Center as location
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                              longitude: -121.891054),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                      longitudeDelta: 0.01))
    
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
            DispatchQueue.main.async {
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
                    // show alert
                    break
                }
            }
        }
    }
}
