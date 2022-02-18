//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Simon Berner on 28.01.22.
//

import Foundation
import OSLog
import CloudKit
import SwiftUI

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

    func createVoiceOverSummary(for location: DDGLocation) -> String {
        let count = checkedInProfiles[location.id, default: []].count
        let personPlurality = count == 1 ? "person" : "people"

        return " \(location.name) \(count) \(personPlurality) checked in."
    }

    @ViewBuilder func createLocationDetailView(for location: DDGLocation, in sizeCategory: ContentSizeCategory) -> some View {
        if sizeCategory >= .accessibilityMedium {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
        } else {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location))
        }
    }
}
