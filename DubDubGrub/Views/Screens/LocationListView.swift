//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI
import OSLog

struct LocationListView: View {

    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        NavigationView {
            List {
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: LocationDetailView(viewModel: LocationDetailViewModel(location: location))) {
                        LocationListCell(location: location)
                    }
                }
            }
            .onAppear {
                // TODO: Refactor into a viewModel
                CloudKitManager.shared.getCheckedInProfilesDictionary { result in
                    switch result {
                    case .success(let checkedInProfiles):
                        print(checkedInProfiles)
                    case .failure(let error):
                        // show alertItem
                        Logger.locationListView.error("Error getting back dictionary: \(error.localizedDescription)")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Grub Spots")
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}
