//
//  CloudKitManager.swift
//  DubDubGrub
//
//  Created by Simon Berner on 01.01.22.
//

import CloudKit

struct CloudKitManager {
    static func getLocations(completed: @escaping (Result <[DDGLocation], Error>) -> Void) {
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
}
