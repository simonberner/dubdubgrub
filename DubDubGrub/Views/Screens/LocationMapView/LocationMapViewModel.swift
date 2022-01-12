//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 05.01.22.
//

import MapKit
import OSLog

// ObservableObject: others can observe instances of this class
// @MainActor: Anything in this class will be rerouted to the main (UI) queue/thread
@MainActor final class LocationMapViewModel: NSObject, ObservableObject {

    @Published var showAlert = false
    @Published var alertItem: AlertItem?
    
    // set Apple WWDC Convention Center as location
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                              longitude: -121.891054),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                      longitudeDelta: 0.01))

    // is an optional because the location services can be turned off on the phone
    var deviceLocationManager: CLLocationManager?

    func checkLocationServicesIsEnabled() {
       if CLLocationManager.locationServicesEnabled() {
           // setup the delegate
           deviceLocationManager = CLLocationManager() // deviceLocationManager?.desiredAccuracy = kCLLocationAccuracyBest // is default
           // assign the delegate to not miss the system calling the locationManagerDidChangeAuthorization(_:) method on the delegate when the location manager finishes initializing (force unwrap because we know it is going to be there)
           deviceLocationManager!.delegate = self
       } else {
           showAlert = true
           alertItem = AlertContext.locationDisabled
       }
    }

    private func checkLocationForAuthorization() {
        guard let deviceLocationManager = deviceLocationManager else { return }

        switch deviceLocationManager.authorizationStatus {

        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            Logger.locationMapViewModel.info("checkLocationForAuthorization: restricted selected")
            showAlert = true
            alertItem = AlertContext.locationRestricted
        case .denied:
            Logger.locationMapViewModel.info("checkLocationForAuthorization: denied selected")
            showAlert = true
            alertItem = AlertContext.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            Logger.locationMapViewModel.info("checkLocationForAuthorization: authorize always/whenInUse selected")
            break
        @unknown default:
            break
        }
    }
    
    /*
     The getLocations() call can be put here. This way you can omit the .onAppear in the View.
     It will get fired when the ViewModel is initialized, which happens each time the LocationMapView redraws.
     */
    //    init() {
    //        getLocations()
    //    }

    func getLocations(for locationManager: LocationManager) {
        CloudKitManager.getLocations { [self] result in
            Task {
                switch result {
                    // getting back an array of locations
                case .success(let locations):
                    locationManager.locations = locations
                    Logger.locationMapViewModel.info("\(locations)")
                case .failure(let error):
                    alertItem = AlertContext.unableToGetLocations
                    showAlert = true
                    Logger.locationMapViewModel.error("\(error.localizedDescription)")
                }
            }
        }
    }

}

// Delegate to listen for location permission changes outside our App
// For code organisation purposes, we put the delegate in an extension rather than
// making the LocationMapView conform to CLLocationManagerDelegate
extension LocationMapViewModel: CLLocationManagerDelegate {
    /*
     The system calls this method when the app creates the related object’s CLLocationManager instance (see above),
     and when the app’s authorization status changes. The status informs the app whether it can access the user’s location.
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // if the user change eg. from .restricted to .authorizedAlways in the Settings, the func is called
        checkLocationForAuthorization()
    }
}
