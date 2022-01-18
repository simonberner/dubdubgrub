//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 18.01.22.
//

import CloudKit
import OSLog

final class ProfileViewModel: ObservableObject {

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var companyName = ""
    @Published var bio = ""
    @Published var avatar = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker = false
    @Published var alertItem: AlertItem?
    @Published var showAlert = false

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

        // Get the UserRecordID from the CK Container
        // TODO: refactor to us async userRecordID()
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                Logger.profileView.error("Fetching user recordID \(recordID.debugDescription) failed: \(error!.localizedDescription)")
                return
            }

            // Get the UserRecord from the CK Public Database
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    Logger.profileView.error("Fetching UserRecord failed: \(error!.localizedDescription)")
                    return
                }

                // Create a reference from the userRecord to the user profileRecord
                // action -> .deleteSelf: when the user profile gets deleted, also delete the associated profile
                // (when the parent gets deleted, also delete (my)self)
                userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)

                // Create a CKOperation to save the userRecord and profileRecord
                let operation = CKModifyRecordsOperation(recordsToSave: [userRecord, profileRecord])
                // completion block
                // (if it was successful we get savedRecords back or deletedRecords which we ignore here, otherwise an error)
                operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
                    guard let savedRecords = savedRecords, error == nil else {
                        Logger.profileView.error("Saving of userRecord and profileRecord to CloudKit failed: \(error!.localizedDescription)")
                        return
                    }

                    Logger.profileView.info("Saved records to CloudKit: \(savedRecords)")
                }

                // run the operation (to save the records)
                CKContainer.default().publicCloudDatabase.add(operation)
            }
        }
    }

    func getProfile() {
        // Get user recordID - network call to CK
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                Logger.profileView.error("Fetching user recordID \(recordID.debugDescription) failed: \(error!.localizedDescription)")
                return
            }
            // Get the UserRecord from the CK Public Database - network call to CK
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    Logger.profileView.error("Fetching UserRecord failed: \(error!.localizedDescription)")
                    return
                }

                let profileReference = userRecord["userProfile"] as! CKRecord.Reference
                let profileRecordID = profileReference.recordID

                // Get the profileRecord - network call to CK
                CKContainer.default().publicCloudDatabase.fetch(withRecordID: profileRecordID) { profileRecord, error in
                    guard let profileRecord = profileRecord, error == nil else {
                        Logger.profileView.error("Fetching profileRecord failed: \(error!.localizedDescription)")
                        return
                    }

                    // Go to the main thread and create a DDGProfile from the above profileRecord
                    // to populate the UI
                    DispatchQueue.main.async { [self] in
                        let profile = DDGProfile(record: profileRecord) // convert
                        firstName = profile.firstName
                        lastName = profile.lastName
                        companyName = profile.companyName
                        bio = profile.bio
                        avatar = profile.getImage(for: .square)
                    }
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
}
