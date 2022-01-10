//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI

struct LocationListView: View {

    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        NavigationView {
            List {
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        LocationListCell(location: location)
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
