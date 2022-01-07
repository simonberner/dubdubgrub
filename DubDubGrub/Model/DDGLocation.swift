//
//  DDGLocation.swift
//  DubDubGrub
//
//  Created by Simon Berner on 30.12.21.
//

import CloudKit

// Object which maps to the DDGLocation CloudKit Record Type
struct DDGLocation: Identifiable {

    static let kName = "name"
    static let kDescription = "description"
    static let kSquareAsset = "squareAsset"
    static let kBannerAsset = "bannerAsset"
    static let kAddress = "address"
    static let kLocation = "location"
    static let kWebsiteURL = "websiteURL"
    static let kPhoneNumber = "phoneNumber"

    let id: CKRecord.ID
    let name: String
    let description: String
    let squareAsset: CKAsset! //implicitly unwrapping of the optional (handling the nil case later on with a default image asset)
    let bannerAsset: CKAsset!
    let address: String
    let location: CLLocation
    let websiteURL: String
    let phoneNumber: String

    // creating our own initializer because we get a CKRecord back when querying CloudKit database
    init(record: CKRecord) {
        id = record.recordID
        name = record[DDGLocation.kName] as? String ?? "N/A" // record is a key-value pair
        description = record[DDGLocation.kDescription] as? String ?? "N/A"
        squareAsset = record[DDGLocation.kSquareAsset] as? CKAsset
        bannerAsset = record[DDGLocation.kBannerAsset] as? CKAsset
        address = record[DDGLocation.kAddress] as? String ?? "N/A"
        location = record[DDGLocation.kLocation] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        websiteURL = record[DDGLocation.kWebsiteURL] as? String ?? "N/A"
        phoneNumber = record[DDGLocation.kPhoneNumber] as? String ?? "N/A"

    }

}
