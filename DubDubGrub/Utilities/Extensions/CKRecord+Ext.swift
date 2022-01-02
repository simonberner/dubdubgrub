//
//  CKRecord+Ext.swift
//  DubDubGrub
//
//  Created by Simon Berner on 02.01.22.
//

import CloudKit

extension CKRecord {
    func convertToDDGLocation() -> DDGLocation { DDGLocation(record: self) }
    func convertToDDGProfile() -> DDGProfile { DDGProfile(record: self)}
}
