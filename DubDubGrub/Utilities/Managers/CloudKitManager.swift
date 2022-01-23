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

    // CloudKitManager is a singleton
    // (Be aware of that this might be a slippery slope for the future when the app grows and we add
    // more and more stuff to the CloudKitManager. The ProfileViewModal already updates the profileRecordID of this instance!)
    static let shared = CloudKitManager()

    // Noone can initialize
    private init() {}

    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?

    // this happens silently in the background on launch of the App
    // (a user does not necesseraly have to be logged in, if she just
    // wants to see who is checked in at which location)
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

    // save/update an Array of CKRecords
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

    // save/update a single CKRecord
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

    func fetchRecord(with id: CKRecord.ID, completed: @escaping (Result<CKRecord, Error>) -> Void) {

        // Get the profileRecord - network call to CK
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
