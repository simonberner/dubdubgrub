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

    // No-one can initialize
    private init() {}

    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?
    let container = CKContainer.default()

//    func getUserRecord() {
//        CKContainer.default().fetchUserRecordID { recordID, error in
//            guard let recordID = recordID, error == nil else {
//                Logger.cloudKitManager.error("Fetching user recordID \(recordID.debugDescription) failed: \(error!.localizedDescription)")
//                return
//            }
//
//            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
//                guard let userRecord = userRecord, error == nil else {
//                    Logger.cloudKitManager.error("Fetching UserRecord failed: \(error!.localizedDescription)")
//                    return
//                }
//
//                self.userRecord = userRecord
//                Logger.cloudKitManager.info("getUserRecord: \(self.userRecord.debugDescription)")
//
//                // Does the userRecord has a reference to a userProfile?
//                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
//                    self.profileRecordID = profileReference.recordID // is nil when a user isn't logged in (in iCloud)
//                }
//            }
//        }
//    }

    /**
     Get the userRecord of the current signed in iCloud user and store it in the instance property userRecord.
     If there is no iCloud account configured, or if access is restricted, a @c CKErrorNotAuthenticated error will be returned.

     This func gets called when the App starts (with the rendering of AppTabView). A user does not  have to be logged in,
     if she just wants to see who is checked in at which location.
     */
    func getUserRecord() async throws {
        let recordID = try await container.userRecordID()
        let record = try await container.publicCloudDatabase.record(for: recordID)
        userRecord = record
        Logger.cloudKitManager.info("getUserRecord: \(self.userRecord.debugDescription)")

        // Does the userRecord has a reference to a userProfile?
        if let profileReference = record["userProfile"] as? CKRecord.Reference {
            profileRecordID = profileReference.recordID // is nil when a user isn't logged in (in iCloud)
        }
    }

//    func getLocations(completed: @escaping (Result <[DDGLocation], Error>) -> Void) {
//        // sort by location name
//        let alphabeticalSort = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
//        // taking baby-steps before using CKQueryOperation:
//        // using the convenience api for doing the basic call to CloudKit
//        // NSPredicate: give back everything that is a DDGLocation
//        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
//        query.sortDescriptors = [alphabeticalSort]
//
//        // request to CloudKit
//        // we get back 2 optional objects from that call:
//        // - an array of 'records' or
//        // - an 'error'
//        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
//            guard let records = records, error == nil else {
//                completed(.failure(error!))
//                return
//            }
//
//            // when we have records
//            let locations = records.map(DDGLocation.init)
//            // pass up the locations
//            completed(.success(locations))
//        }
//    }

    /**
     Get all available locations where users can visit

     - Returns: A completion handler containing an array with all the locations available in the CloudKit database
     */
    func getLocations() async throws -> [DDGLocation] {
        // sort by location name
        let alphabeticalSort = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        // NSPredicate: give back everything that is a DDGLocation
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [alphabeticalSort]

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in try? result.get()} // compactMap filters out the nils
        return records.map(DDGLocation.init)
}

    /**
     Get the currently checked-in user profiles for an individual location

     - Parameter locationID: The locationID to get the checkedIn profiles for
     - Returns: A completion handler with the Result<[DDGProfiles], Error> (where [DDGProfile] is an Array containing the checkedIn profiles for this location)
     */
    func getCheckedInProfiles(for locationID: CKRecord.ID) async throws -> [DDGProfile] {
        // CKReferences - Back pointers
        let reference = CKRecord.Reference(recordID: locationID, action: .none)
        // any DDGProfile who's 'isCheckedIn' property is equals to the 'reference'
        // ('%@' stands for 'placeholder', where we put the reference in)
        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in try? result.get() }
        return records.map(DDGProfile.init)
    }

    /**
     Get all the checkedIn user profiles for all the locations (this is the most expensive CK call) and put them into a Dictionary: [DDGLocation : [DDGProfile]]
     -> func for the LocationListViewModel

     - Returns: a non-optional dictionary [CKRecord.ID : [DDGProfile]]
     - Throws: an Error
     */
    func getCheckedInProfilesDictionary() async throws -> [CKRecord.ID : [DDGProfile]] {
        Logger.cloudKitManager.info("✅ fired off")
        // set the filter
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        // create the query with the above filter
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)

        // Initialize empty dictionary
        var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]

        let (matchResults, cursor) = try await container.publicCloudDatabase.records(matching: query, resultsLimit: 1)
        let records = matchResults.compactMap { _, result in try? result.get() }

        // iterate through the array and build the dictionary
        for record in records {
            // create a profile from the record we get back
            let profile = DDGProfile(record: record)

            // check what the referenceId is (that is the location where that profile is checked-in to)
            // continue: if a record does not have a locationReference, continue with the next iteration in the for-loop
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }

            // in the dictionary: (17:10)
            // Go ahead and look for the key of this location recordId, when an array of DDGProfile exists at that recordId,
            // we are going to append the profile to it.
            // if there is not already a DDGProfile at that location recordID, we are appending the profile to a fresh new Array
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }

        Logger.cloudKitManager.info(" first 1️⃣ checkedInProfiles = \(checkedInProfiles)")
        // if we have a cursor, there is more to download
        guard let cursor = cursor else { return checkedInProfiles }

        do {
            return try await continueWithCheckedInProfileDict(cursor: cursor, dictionary: checkedInProfiles)
        } catch {
            throw error
        }

    }

    private func continueWithCheckedInProfileDict(cursor: CKQueryOperation.Cursor,
                                                  dictionary: [CKRecord.ID: [DDGProfile]]) async throws -> [CKRecord.ID: [DDGProfile]] {

        var checkedInProfiles = dictionary

        let (matchResults, cursor) = try await container.publicCloudDatabase.records(continuingMatchFrom: cursor, resultsLimit: 1)
        // in the matchResults ignore the recordID and try to get the record from a result
        // if a record has an error, return nil and the compactMap will filter out the nil and
        // finally provide a clean array of records
        let records = matchResults.compactMap { _, result in try? result.get() }

        for record in records {
            let profile = DDGProfile(record: record)
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }

        Logger.cloudKitManager.info(" called recursively ⭕️ checkedInProfiles = \(checkedInProfiles)")
        guard let cursor = cursor else { return checkedInProfiles }

        do {
            return try await continueWithCheckedInProfileDict(cursor: cursor, dictionary: checkedInProfiles)
        } catch {
            throw error
        }
    }

    /**
     Get all the checkedIn user profiles count for all the locations and put them into a Dictionary: [DDGLocation : Int]
     -> func for the LocationMapViewModel

     - Returns: A completion handler with the Result containing a dictionary [DDGLocation : Int]
     */
    func getCheckedInProfilesCount(completed: @escaping (Result<[CKRecord.ID : Int], Error>) -> Void) {
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        // CKQueryOperation: we get back 2 closures:
        // - first closure feeds us the records as they are being downloaded
        // - second closure fires of when the query is done
        let operation = CKQueryOperation(query: query) // by using CKQueryOperation we get only the keys back we actually want
        operation.desiredKeys = [DDGProfile.kIsCheckedIn] // for the profile count we just need to download the isCheckedIn reference (uuid)

        // Build dictionary (locationId and Int for the count)
        var checkedInProfiles: [CKRecord.ID : Int] = [:]

        // The closure to execute when a record (that has matched the above predicate) becomes available.
        operation.recordFetchedBlock = { record in
            // check what the referenceId is (that is the location where that profile is checked-in to)
            // cast it into the specific type
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { return }

            // how many counts are at each location
            if let count = checkedInProfiles[locationReference.recordID] {
                // if we have a count for the location, we
                checkedInProfiles[locationReference.recordID] = count + 1

            } else {
                // if the count at a location is nil, go and make the count = 1
                // because that is the first time we have seen this record when building the dictionary
                checkedInProfiles[locationReference.recordID] = 1
            }
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
                Logger.cloudKitManager.error("Saving of userRecord and profileRecord to CloudKit failed: \(error!.localizedDescription)")
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
