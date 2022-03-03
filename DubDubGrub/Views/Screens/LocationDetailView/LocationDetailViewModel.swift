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

@MainActor final class LocationDetailViewModel: ObservableObject {


    @Published var alertItem: AlertItem?
    @Published var showAlert = false
    @Published var isShowingProfileModalView = false
    @Published var isShowingProfileModalSheet = false
    @Published var checkedInProfiles: [DDGProfile] = []
    @Published var isCheckedIn = false
    @Published var isLoading = false

    var location: DDGLocation
    var selectedProfile: DDGProfile?
    var buttonColor: Color { isCheckedIn ? .grubRed : .brandPrimary }
    var imageName: String { isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark" }
    var buttonA11yLabel: String { isCheckedIn ? "Check out of location" : "Check into location" }

    init(location: DDGLocation) { self.location = location }

    func getColumns(for dynamicTypeSize: DynamicTypeSize) -> [GridItem] {
        let numberOfColumns = dynamicTypeSize >= .accessibility3 ? 1 : 3
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
    }

    func getDirectionsToLocation() {
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.phoneNumber = location.phoneNumber

        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    func getCheckedInStatus() {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            Logger.locationDetailViewModel.info("getCheckedInStatus: user is not signed-in to iCloud.")
            return
        }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let record):
                    // does the DDGProfile.kIsCheckedIn (casting it to a Reference) has a reference?
                    if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        isCheckedIn = reference.recordID == location.id
                        Logger.locationDetailViewModel.info("User is checkedIn to: \(location.name)")
                    } else {
                        isCheckedIn = false
                        Logger.locationDetailViewModel.info("User is checkedOut - reference is nil")
                    }
                case .failure(let error):
                    showAlert = true
                    alertItem = AlertContext.unableToGetCheckInStatus
                    Logger.locationDetailViewModel.error("Failed to fetch record: \(error.localizedDescription)")
                }
            }
        }
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
            showAlert = true
            alertItem = AlertContext.unableToGetProfile
            return
        }

        showLoadingView()
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            switch result {
            case .success(let record):
                // Create a reference to the location
                switch checkInStatus {
                case .checkedIn:
                    record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                    record[DDGProfile.kIsCheckedInNilCheck] = 1
                case .checkedOut:
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                }

                // Save the updated profile to CloudKit
                CloudKitManager.shared.save(record: record) { result in
                    DispatchQueue.main.async {
                        hideLoadingView()
                        switch result {
                        case .success(let record):
                            HapticManager.playSuccess()
                            let profile = DDGProfile(record: record)
                            switch checkInStatus {
                            case .checkedIn:
                                checkedInProfiles.append(profile)
                                Logger.locationDetailViewModel.info("✅ \(profile.firstName) has checkedIn successfully")
                            case .checkedOut:
                                // for any DDGProfile in the Array where its id is equal to the profile.id, remove it
                                checkedInProfiles.removeAll(where: {$0.id == profile.id})
                                Logger.locationDetailViewModel.info("✅ \(profile.firstName) has checkedOut successfully")
                            }

                            isCheckedIn.toggle()

                        case .failure(_):
                            showAlert = true
                            alertItem = AlertContext.updateProfileFailure
                            Logger.locationDetailViewModel.info("❌ Error saving record")
                        }
                    }
                }

            case .failure(_):
                hideLoadingView()
                showAlert = true
                alertItem = AlertContext.checkInOutFailed
                Logger.locationDetailViewModel.info("❌ Error fetching record")
            }
        }
    }

    func getCheckedInProfiles() {
        showLoadingView()

        Task {
            do {
                checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfiles(for: location.id)
                hideLoadingView()
            } catch {
                hideLoadingView()
                showAlert = true
                alertItem = AlertContext.unableToGetCheckedInProfiles
                Logger.locationDetailViewModel.error("getCheckedInProfiles failed! \(error.localizedDescription)")
            }
        }
    }

    func show(_ profile: DDGProfile, in dynamicTypeSize: DynamicTypeSize) {
        selectedProfile = profile
        if dynamicTypeSize >= .accessibility3 {
            isShowingProfileModalSheet = true
        } else {
            isShowingProfileModalView = true
        }
    }

    // Helper functions
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }

}

enum CheckInStatus { case checkedIn, checkedOut }
