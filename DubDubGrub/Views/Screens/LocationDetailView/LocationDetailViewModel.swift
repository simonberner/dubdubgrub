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
    @Published var checkedInProfiles: [DDGProfile] = []
    @Published var isCheckedIn = false

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
                    let profile = DDGProfile(record: record)
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            switch checkInStatus {
                            case .checkedIn:
                                checkedInProfiles.append(profile)
                                Logger.locationDetailViewModel.info("✅ \(profile.firstName) has checkedIn successfully")
                            case .checkedOut:
                                // for any DDGProfile in the Array where its id is equal to the profile.id, remove it
                                checkedInProfiles.removeAll(where: {$0.id == profile.id})
                                Logger.locationDetailViewModel.info("✅ \(profile.firstName) has checkedOut successfully")
                            }

                            isCheckedIn = checkInStatus == .checkedIn

                        case .failure(_):
                            Logger.locationDetailViewModel.info("❌ Error saving record")
                        }
                    }
                }

            case .failure(_):
                Logger.locationDetailViewModel.info("❌ Error fetching record")
            }
        }
    }

    func getCheckedInProfiles() {
        CloudKitManager.shared.getCheckedInProfiles(for: location.id) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let profiles):
                    // update the Array of checkedIn profiles
                    checkedInProfiles = profiles
                case .failure(let error):
                    // show alert
                    Logger.locationDetailViewModel.error("getCheckedInProfiles failed! \(error.localizedDescription)")
                }
            }
        }
    }

}

enum CheckInStatus { case checkedIn, checkedOut }
