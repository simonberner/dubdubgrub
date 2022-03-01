//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI

struct LocationListView: View {

    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = LocationListViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        // TODO: add pull and refresh of the Navigation List in the view
        NavigationView {
            List {
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: viewModel.createLocationDetailView(for: location, in: dynamicTypeSize)) {
                        LocationListCell(location: location, profiles: viewModel.checkedInProfiles[location.id, default: []])
                        // if nobody is checked into the location, we won't have the location.id in the checkedInProfiles dictionary. We then return an empty array (if nothing is at that key)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text(viewModel.createVoiceOverSummary(for: location)))
                    }
                }
            }
            .onAppear { viewModel.getCheckedInProfilesDictionary() }
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
