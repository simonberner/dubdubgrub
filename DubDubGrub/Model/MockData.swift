//
//  MockData.swift
//  DubDubGrub
//
//  Created by Simon Berner on 31.12.21.
//

import CloudKit

struct MockData {

    // computed property
    static var location: CKRecord {
        // implicit get
        // fyi: the property is computed each time it is accessed
        let record = CKRecord(recordType: RecordType.location)
        record[DDGLocation.kName] = "Simon's Grill and Chill"
        record[DDGLocation.kAddress] = "123 Chill Street"
        record[DDGLocation.kDescription] = "This is a description. Isn't it super cool! Not sure how long to make it to test 3 lines at once."
        record[DDGLocation.kWebsiteURL] = "https://simonberner.dev"
        record[DDGLocation.kLocation] = CLLocation.init(latitude: 37.331516, longitude: -121.891054)
        record[DDGLocation.kPhoneNumber] = "+41 079 123 45 67"

        return record
    }
}
