//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.01.22.
//

import SwiftUI
import MapKit
import CloudKit
import OSLog

final class LocationDetailViewModel: ObservableObject {


    @Published var alertItem: AlertItem?
    @Published var showAlert = false
    @Published var isShowingProfileModalView = false

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

    func updateCheckInStatus(to checkInStatus: CheckInStatus) {
        // Retrieve the DDGProfile

        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            // show alert
            return
        }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            switch result {
            case .success(let record):
                // Create a reference to the location
                switch checkInStatus {
                case .checkedIn:
                    record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                case .checkedOut:
                    record[DDGProfile.kIsCheckedIn] = nil
                }

                // Save the updated profile to CloudKit
                CloudKitManager.shared.save(record: record) { result in
                    switch result {
                    case .success(_):
                        //update our checkedInProfiles array
                        Logger.locationDetailViewModel.info("✅ Checked In/Out successfuly")

                    case .failure(_):
                        Logger.locationDetailViewModel.info("❌ Error saving record")
                    }
                }

            case .failure(_):
                Logger.locationDetailViewModel.info("❌ Error fetching record")
            }
        }
    }

}

enum CheckInStatus { case checkedIn, checkedOut }
