//
//  DDGProfile.swift
//  DubDubGrub
//
//  Created by Simon Berner on 31.12.21.
//

import CloudKit
import UIKit

// Object which maps to the DDGProfile CloudKit Record Type
struct DDGProfile: Identifiable {

    static let kFirstName = "firstName"
    static let kLastName = "lastName"
    static let kAvatar = "avatar"
    static let kCompanyName = "companyName"
    static let kBio = "bio"
    static let kIsCheckedIn = "isCheckedIn"

    let id: CKRecord.ID
    let firstName: String
    let lastName: String
    let avatar: CKAsset! //implicitly unwrapping of the optional (handling the nil case later on with a default image asset)
    let companyName: String
    let bio: String
    let isCheckedIn: CKRecord.Reference? = nil

    // creating our own initializer because we get a CKRecord back when querying CloudKit database
    init(record: CKRecord) {
        id = record.recordID
        firstName = record[DDGProfile.kFirstName] as? String ?? "N/A" // record is a key-value pair
        lastName = record[DDGProfile.kLastName] as? String ?? "N/A"
        avatar = record[DDGProfile.kAvatar] as? CKAsset
        companyName = record[DDGProfile.kCompanyName] as? String ?? "N/A"
        bio = record[DDGProfile.kBio] as? String ?? "N/A"
    }

    func getImage(for dimension: ImageDimension) -> UIImage {
        let placeholder = dimension.placeholderImage

        switch dimension {
        case .square:
            return avatar?.convertToUIImage(in: dimension) ?? placeholder
        case .banner:
            return avatar?.convertToUIImage(in: dimension) ?? placeholder
        case .avatar:
            return avatar?.convertToUIImage(in: dimension) ?? placeholder
        }
    }

}
