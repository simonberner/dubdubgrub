//
//  CloudKitManager.swift
//  DubDubGrub
//
//  Created by Simon Berner on 01.01.22.
//

import CloudKit
import OSLog
import UIKit

final class CloudKitManager {

    /**
     The CloudKitManager is a singleton

     Be aware of that having a specific instance of this class as a singleton, might be a slippery slope for the future growth of the app.
     More features means also that more other instances will need to access the singleton and change it accordingly.
     (e.g.The ProfileViewModal already updates the profileRecordID of this instance!)
     */
    static let shared = CloudKitManager()

    // Noone can initialize
    private init() {}

    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?

    /**
     Get the userRecord of the current signed in iCloud user and store it in the instance property userRecord.
     If there is no iCloud account configured, or if access is restricted, a @c CKErrorNotAuthenticated error will be returned.

     This func gets called when the App starts (with the rendering of AppTabView). A user does not  have to be logged in,
     if she just wants to see who is checked in at which location.
     */
    func getUserRecord() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                Logger.cloudKitManager.error("Fetching user recordID \(recordID.debugDescription) failed: \(error!.localizedDescription)")
                return
            }

            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    Logger.profileView.error("Fetching UserRecord failed: \(error!.localizedDescription)")
                    return
                }

                self.userRecord = userRecord
                Logger.cloudKitManager.info("getUserRecord: \(self.userRecord.debugDescription)")

                // Does the userRecord has a reference to a userProfile?
                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
                    self.profileRecordID = profileReference.recordID // is nil when a user isn't logged in (in iCloud)
                }
            }
        }
    }

    /**
     Get all available locations where users can visit

     - Returns: A completion handler containing an array with all the locations available in the CloudKit database
     */
    func getLocations(completed: @escaping (Result <[DDGLocation], Error>) -> Void) {
        // sort by location name
        let alphabeticalSort = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        // taking baby-steps before using CKQueryOperation:
        // using the convenience api for doing the basic call to CloudKit
        // NSPredicate: give back everything that is a DDGLocation
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [alphabeticalSort]

        // request to CloudKit
        // we get back 2 optional objects from that call:
        // - an array of 'records' or
        // - an 'error'
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            // make sure error is nil before we move on
            guard error == nil else {
                completed(.failure(error!))
                return
            }

            // if records is nil, return
            guard let records = records else { return }

            // when we have records
            let locations = records.map { $0.convertToDDGLocation() } // shorthand parameter syntax

            // pass up the locations
            completed(.success(locations))
        }

    }

    /**
     Get the currently checked-in user profiles for an individual location

     - Parameter locationID: The locationID to get the checkedIn profiles for
     - Returns: A completion handler with the Result<[DDGProfiles], Error> (where [DDGProfile] is an Array containing the checkedIn profiles for this location)
     */
    func getCheckedInProfiles(for locationID: CKRecord.ID, completed: @escaping (Result<[DDGProfile], Error>) -> Void) {
        // CKReferences - Back pointers
        let reference = CKRecord.Reference(recordID: locationID, action: .none)
        // any DDGProfile who's 'isCheckedIn' property is equals to the 'reference'
        // ('%@' stands for 'placeholder', where we put the reference in)
        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)

        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                completed(.failure(error!))
                return
            }
            let profiles = records.map { $0.convertToDDGProfile() }
            // pass up all the checkedIn profiles (as a DDGProfile Array)
            completed(.success(profiles))
        }
    }

    /**
     Get all the checkedIn user profiles for all the locations (this is the most expensive CK call) and put them into a Dictionary: [DDGLocation : [DDGProfile]]

     - Returns: A completion handler with the Result containing a dictionary [DDGLocation : [DDGProfile]]
     */
    func getCheckedInProfilesDictionary(completed: @escaping (Result<[CKRecord.ID : [DDGProfile]], Error>) -> Void) {
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        // CKQueryOperation: we get back 2 closures:
        // - first closure feeds us the records as they are being downloaded
        // - second closure fires of when the query is done
        let operation = CKQueryOperation(query: query) // by using CKQueryOperation we get only the keys back we actually want
//        operation.desiredKeys = [DDGProfile.kIsCheckedIn, DDGProfile.kAvatar] // we could just download the isCheckedIn reference and the avatar
        // the cost of downloading everything from all the users is in our context with that data negligible.

        // Build dictionary
        var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]

        // The closure to execute when a record (that has matched the above predicate) becomes available.
        operation.recordFetchedBlock = { record in
            // create a profile from the record we get back
            let profile = DDGProfile(record: record)

            // check what the referenceId is (that is the location where that profile is checked-in to)
            guard let locationReference = profile.isCheckedIn else { return }

            // in the dictionary: (17:10)
            // Go ahead and look for the key of this location recordId, when an array of DDGProfile exists at that recordId,
            // we are going to append the profile to it.
            // if there is not already a DDGProfile at that location recordID, we are appending the profile to a fresh new Array
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }

        // The closure to execute after CloudKit retrieves all of the records.
        operation.queryCompletionBlock = { cursor, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }

            // TODO: handle cursor later on
            // (cursor for pagination: you pass in the cursor to a next query so that it knows where to start querying the record

            completed(.success(checkedInProfiles))
        }

        // run the operation
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    /**
     Save or update an Array of CKRecords

     - Parameter records: The Array of records to save or update
     - Returns: A completion handler with the Result<[CKRecord], Error>. [CKRecord]
     */
    func batchSave(records: [CKRecord], completed: @escaping (Result<[CKRecord], Error>) -> Void) {

        let operation = CKModifyRecordsOperation(recordsToSave: records)
        // completion block
        // (if it was successful we get savedRecords back or deletedRecords which we ignore here, otherwise an error)
        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
            guard let savedRecords = savedRecords, error == nil else {
                Logger.profileView.error("Saving of userRecord and profileRecord to CloudKit failed: \(error!.localizedDescription)")
                completed(.failure(error!))
                return
            }

            completed(.success(savedRecords))
            Logger.profileView.info("Saved records to CloudKit: \(savedRecords)")
        }

        // run the operation (to save the records)
        CKContainer.default().publicCloudDatabase.add(operation)

    }

    /**
     Save or Update  a single CKRecord - Network call to CloudKit

     - Parameter record: The CKRecord to save/update
     - Returns: A completion handler with the Result<CKRecord, Error>
     */
    func save(record: CKRecord, completed: @escaping (Result<CKRecord, Error>) -> Void) {
        CKContainer.default().publicCloudDatabase.save(record) { record, error in
            guard let record = record, error == nil else {
                completed(.failure(error!))
                Logger.profileView.error("Fetching profileRecord failed: \(error!.localizedDescription)")
                return
            }

            completed(.success(record))
        }
    }

    /**
     Get the profileRecord  - Network call to CloudKit

     - Parameter id: The CKRecord.ID to fetch the Record  with
     - Returns: A completion handler with the Result<CKRecord, Error>
     */
    func fetchRecord(with id: CKRecord.ID, completed: @escaping (Result<CKRecord, Error>) -> Void) {

        CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { record, error in
            guard let record = record, error == nil else {
                completed(.failure(error!))
                Logger.profileView.error("Fetching profileRecord failed: \(error!.localizedDescription)")
                return
            }

            completed(.success(record))
        }
    }
}
