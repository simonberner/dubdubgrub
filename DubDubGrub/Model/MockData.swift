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

    static var profile: CKRecord {
        let record = CKRecord(recordType: RecordType.profile)
        record[DDGProfile.kFirstName] = "Simon"
        record[DDGProfile.kLastName] = "Berner"
        record[DDGProfile.kCompanyName] = "Best company ever"
        record[DDGProfile.kBio] = "This is my bio, I hope it's not too long because I can't check character count"

        return record
    }

    static var chipotle: CKRecord {
        let record = CKRecord(recordType: RecordType.location, recordID: CKRecord.ID(recordName: "A3F5ED50-AFA6-12A9-F258-45550D2757BC"))
        record[DDGLocation.kName] = "Chipotle"
        record[DDGLocation.kAddress] = "1 S Market St Ste 40"
        record[DDGLocation.kDescription] = "Our local San Jose One South Market Chipotle Mexican Grill is cultivating a better world by serving responsibly sourced, classically-cooked, real food."
        record[DDGLocation.kWebsiteURL] = "https://locations.chipotle.com/ca/san-jose/1-s-market-st"
        record[DDGLocation.kLocation] = CLLocation(latitude: 37.334967, longitude: -121.892566)
        record[DDGLocation.kPhoneNumber] = "408-938-0919"

        return record
    }
}
