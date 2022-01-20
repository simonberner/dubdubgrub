//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.01.22.
//

import SwiftUI
import MapKit

final class LocationDetailViewModel: ObservableObject {


    @Published var alertItem: AlertItem?
    @Published var showAlert = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var location: DDGLocation

    init(location: DDGLocation) {
        self.location = location
    }

    func getDirectionsToLocation() {
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.phoneNumber = location.phoneNumber

        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    func callLocation() {
        guard let url = URL(string: "tel://\(location.phoneNumber)") else {
            showAlert = true
            alertItem = AlertContext.invalidPhoneNumber
            return
        }
        // Check if the device can actually deep link into another App
        if UIApplication.shared.canOpenURL(url) {
            // Deep linking between Apps
            UIApplication.shared.open(url)
        } else {
            // Show Alert: Calls on this device are not possible!
        }
    }

}
