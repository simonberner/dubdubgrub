//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 18.01.22.
//

import CloudKit
import OSLog
import SwiftUI

final class ProfileViewModel: ObservableObject {

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var companyName = ""
    @Published var bio = ""
    @Published var avatar = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker = false
    @Published var alertItem: AlertItem?
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isCheckedIn = false

    private var existingProfileRecord: CKRecord? {
        didSet { profileContext = .update }
    }

    var profileContext: ProfileContext = .create

    private func isValidProfile() -> Bool {

        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count <= 100 else { return false }

        return true
    }

    func createUserProfile() {
        // Have we a valid profile?
        guard isValidProfile() else {
            showAlert = true
            alertItem = AlertContext.invalidProfileForm
            return
        }

        let profileRecord = createProfileRecord()

        guard let userRecord = CloudKitManager.shared.userRecord else {
            showAlert = true
            alertItem = AlertContext.noUserRecord
            return
        }

        // create the reference userRecord (Users) to profileRecord (DDGProfile)
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)

        showLoadingView()
        CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) { result in
            DispatchQueue.main.sync { [self] in
                hideLoadingView()

                switch result {
                case .success(let records):
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        CloudKitManager.shared.profileRecordID = record.recordID // update singleton (if a user creates its profile for the very first time here in the App)
                    }
                    showAlert = true
                    alertItem = AlertContext.createProfileSuccess
                case .failure(_):
                    showAlert = true
                    alertItem = AlertContext.createProfileFailure
                }

            }
        }
    }

    // Update the already exiting profileRecord
    func updateProfile() {
        guard isValidProfile() else {
            showAlert = true
            alertItem = AlertContext.invalidProfileForm
            return
        }

        guard let profileRecord = existingProfileRecord else {
            showAlert = true
            alertItem = AlertContext.unableToGetProfile
            return
        }

        // The CK backend is smart enough to only update the fields which
        // actually have new values
        profileRecord[DDGProfile.kFirstName] = firstName
        profileRecord[DDGProfile.kLastName] = lastName
        profileRecord[DDGProfile.kCompanyName] = companyName
        profileRecord[DDGProfile.kBio] = bio
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()

        showLoadingView()
        CloudKitManager.shared.save(record: profileRecord) { result in
            // UI updates have to be on the main thread
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                case .success(_):
                    showAlert = true
                    alertItem = AlertContext.updateProfileSuccess
                case .failure(_):
                    showAlert = true
                    alertItem = AlertContext.updateProfileFailure
                }
            }
        }
    }

    func getProfile() {

        guard let userRecord = CloudKitManager.shared.userRecord else {
            showAlert = true
            alertItem = AlertContext.noUserRecord
            return
        }

        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
        let profileRecordID = profileReference.recordID

        showLoadingView()
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
            // Go to the main thread and create a DDGProfile to redraw the UI with the data
            DispatchQueue.main.async { [self] in
                hideLoadingView()

                switch result {
                case .success(let record):
                    existingProfileRecord = record

                    let profile = DDGProfile(record: record) // convert
                    firstName = profile.firstName
                    lastName = profile.lastName
                    companyName = profile.companyName
                    bio = profile.bio
                    avatar = profile.getImage(for: .square)
                case .failure(let error):
                    showAlert = true
                    alertItem = AlertContext.unableToGetProfile
                    Logger.profileViewModel.info("Could not get the profile: \(error.localizedDescription)")
                }
            }
        }
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
                    // check if a user is checked in at some location
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        isCheckedIn = true
                    } else {
                        isCheckedIn = false
                        Logger.locationDetailViewModel.info("User is checkedOut - reference is nil")
                    }

                case .failure(_):
                    // don't show any alert
                    // design choice: let it fail silently because the Check Out is a "secondary feature"
                    break
                }
            }
        }
    }

    // Checkout from any location
    func checkOut() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.unableToGetProfile
            return
        }

        CloudKitManager.shared.fetchRecord(with: profileID) { [self] result in
            switch result {
            case .success(let record):
                record[DDGProfile.kIsCheckedIn] = nil
                record[DDGProfile.kIsCheckedInNilCheck] = nil

                CloudKitManager.shared.save(record: record) { [self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            isCheckedIn = false
                        case .failure(_):
                            showAlert = true
                            alertItem = AlertContext.checkInOutFailed
                        }
                    }
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    showAlert = true
                    alertItem = AlertContext.checkInOutFailed
                }
            }
        }
    }

    // Create a CKRecord from the profile data
    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[DDGProfile.kFirstName] = firstName
        profileRecord[DDGProfile.kLastName] = lastName
        profileRecord[DDGProfile.kCompanyName] = companyName
        profileRecord[DDGProfile.kBio] = bio
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()

        return profileRecord
    }

    // Helper functions
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
