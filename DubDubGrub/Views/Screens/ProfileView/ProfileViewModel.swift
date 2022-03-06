//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 18.01.22.
//

import CloudKit
import OSLog
import SwiftUI

extension ProfileView {
    
    @MainActor final class ProfileViewModel: ObservableObject {

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
        var buttonTitle: String { profileContext == .create ? "Create Profile" : "Update Profile" }

        private func isValidProfile() -> Bool {

            guard !firstName.isEmpty,
                  !lastName.isEmpty,
                  !companyName.isEmpty,
                  !bio.isEmpty,
                  avatar != PlaceholderImage.avatar,
                  bio.count <= 100 else { return false }

            return true
        }

        func determineButtonAction() {
            profileContext == .create ? createUserProfile() : updateProfile()
        }

        private func createUserProfile() {
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

            Task {
                do {
                    let records = try await CloudKitManager.shared.batchSave(records: [userRecord, profileRecord])
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        CloudKitManager.shared.profileRecordID = record.recordID // update singleton (if a user creates its profile for the very first time here in the App)
                    }
                    hideLoadingView()
                    showAlert = true
                    alertItem = AlertContext.createProfileSuccess
                } catch {
                    hideLoadingView()
                    showAlert = true
                    alertItem = AlertContext.createProfileFailure
                }
            }
        }

        // Update the already exiting profileRecord
        private func updateProfile() {
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

            Task {
                do {
                    let _ = try await CloudKitManager.shared.save(record: profileRecord)
                    hideLoadingView()
                    showAlert = true
                    alertItem = AlertContext.updateProfileSuccess
                } catch {
                    hideLoadingView()
                    showAlert = true
                    alertItem = AlertContext.updateProfileFailure
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

            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    existingProfileRecord = record

                    let profile = DDGProfile(record: record) // convert
                    firstName = profile.firstName
                    lastName = profile.lastName
                    companyName = profile.companyName
                    bio = profile.bio
                    avatar = profile.getImage(for: .square)
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    showAlert = true
                    alertItem = AlertContext.unableToGetProfile
                    Logger.profileViewModel.info("Could not get the profile: \(error.localizedDescription)")
                }
            }
        }

        func getCheckedInStatus() {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                Logger.locationDetailViewModel.info("getCheckedInStatus: user is not signed-in to iCloud.")
                return
            }

            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    // check if a user is checked in at some location
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        isCheckedIn = true
                    } else {
                        isCheckedIn = false
                        Logger.locationDetailViewModel.info("User is checkedOut - reference is nil")
                    }
                } catch {
                    // don't show any alert
                    // design choice: let it fail silently because the Check Out is a "secondary feature"
                    Logger.locationDetailViewModel.info("Unable to get checked in status")
                }
            }
        }

        // Checkout from any location
        func checkOut() {
            guard let profileID = CloudKitManager.shared.profileRecordID else {
                alertItem = AlertContext.unableToGetProfile
                return
            }

            showLoadingView()

            // structured concurrency
            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileID)
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil

                    // continue on if the above succeeds
                    _ = try await CloudKitManager.shared.save(record: record)
                    HapticManager.playSuccess()
                    isCheckedIn = false
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    showAlert = true
                    alertItem = AlertContext.checkInOutFailed
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

}
