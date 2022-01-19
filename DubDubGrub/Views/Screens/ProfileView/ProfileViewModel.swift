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

    func isValidProfile() -> Bool {

        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count <= 100 else { return false }

        return true
    }

    func saveUserProfile() {
        // Have we a valid profile?
        guard isValidProfile() else {
            showAlert = true
            alertItem = AlertContext.invalidProfileForm
            return
        }

        let profileRecord = createProfileRecord()

        guard let userRecord = CloudKitManager.shared.userRecord else {
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
                case .success(_):
                    alertItem = AlertContext.createProfileSuccess
                case .failure(_):
                    alertItem = AlertContext.createProfileFailure
                }

            }
        }
    }

    func getProfile() {

        guard let userRecord = CloudKitManager.shared.userRecord else {
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
                    let profile = DDGProfile(record: record) // convert
                    firstName = profile.firstName
                    lastName = profile.lastName
                    companyName = profile.companyName
                    bio = profile.bio
                    avatar = profile.getImage(for: .square)
                case .failure(_):
                    alertItem = AlertContext.unableToGetProfile
                    break
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
