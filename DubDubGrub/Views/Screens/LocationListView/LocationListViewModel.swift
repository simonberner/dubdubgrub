//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 28.01.22.
//

import Foundation
import OSLog
import CloudKit

final class LocationListViewModel: ObservableObject {

    @Published var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
    @Published var alertItem: AlertItem?
    @Published var showAlert = false

    func getCheckedInProfilesDictionary() {
        CloudKitManager.shared.getCheckedInProfilesDictionary { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(let error):
                    showAlert = true
                    alertItem = AlertContext.unableToGetAllCheckedInProfiles
                    Logger.locationListViewModel.error("Error getting back dictionary: \(error.localizedDescription)")
                }
            }
        }
    }
}
