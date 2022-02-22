//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 31.01.22.
//

import CoreLocation
import OSLog
import SwiftUI

final class AppTabViewModel: NSObject, ObservableObject {

    @Published var isShowingOnboardView = false
    @Published var showAlert = false
    @Published var alertItem: AlertItem?
    // @AppStorage is a property wrapper type that reflects a value from UserDefaults
    // and invalidates a view on a change in value in that user default.
    @AppStorage("hasSeenOnboardView") var hasSeenOnboardView = false {
        didSet { isShowingOnboardView = hasSeenOnboardView }
    }

    // is an optional because the location services can be turned off on the phone
    var deviceLocationManager: CLLocationManager?
    let keyHasSeenOnboardView = "hasSeenOnboardView"

    func runStartupChecks() {
        if !hasSeenOnboardView {
            hasSeenOnboardView = true
        } else {
            checkLocationServicesIsEnabled()
        }
    }

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
            Logger.appTabViewModel.info("checkLocationForAuthorization: restricted selected")
            showAlert = true
            alertItem = AlertContext.locationRestricted
        case .denied:
            Logger.appTabViewModel.info("checkLocationForAuthorization: denied selected")
            showAlert = true
            alertItem = AlertContext.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            Logger.appTabViewModel.info("checkLocationForAuthorization: authorize always/whenInUse selected")
            break
        @unknown default:
            break
        }
    }

}

// Delegate to listen for location permission changes outside our App
// For code organisation purposes, we put the delegate in an extension rather than
// making the LocationMapView conform to CLLocationManagerDelegate
extension AppTabViewModel: CLLocationManagerDelegate {
    /*
     The system calls this method when the app creates the related object’s CLLocationManager instance (see above),
     and when the app’s authorization status changes. The status informs the app whether it can access the user’s location.
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // if the user change eg. from .restricted to .authorizedAlways in the Settings, the func is called
        checkLocationForAuthorization()
    }
}
