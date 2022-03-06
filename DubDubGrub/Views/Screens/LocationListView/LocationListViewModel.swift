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

extension LocationListView {

    @MainActor final class LocationListViewModel: ObservableObject {
        @Published var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
        @Published var alertItem: AlertItem?
        @Published var showAlert = false

        func getCheckedInProfilesDictionary() async {
            do {
                checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfilesDictionary()
                Logger.locationListViewModel.info("getCheckedInProfilesDictionary: called/refresh")
            } catch {
                showAlert = true
                alertItem = AlertContext.unableToGetAllCheckedInProfiles
                Logger.locationListViewModel.error("Error getting back dictionary: \(error.localizedDescription)")
            }
        }

        func createVoiceOverSummary(for location: DDGLocation) -> String {
            let count = checkedInProfiles[location.id, default: []].count
            let personPlurality = count == 1 ? "person" : "people"

            return " \(location.name) \(count) \(personPlurality) checked in."
        }

        @ViewBuilder func createLocationDetailView(for location: DDGLocation, in dynamicTypeSize: DynamicTypeSize) -> some View {
            if dynamicTypeSize >= .accessibility3 {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
            } else {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location))
            }
        }
    }
}


