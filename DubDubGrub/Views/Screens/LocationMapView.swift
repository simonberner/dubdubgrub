//
//  LocationMapView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI
import MapKit
import OSLog

struct LocationMapView: View {

    // set Apple WWDC Convention Center as location
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                                  longitude: -121.891054),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                          longitudeDelta: 0.01))
    @State var showAlert = false

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region).ignoresSafeArea(edges: .top)

            VStack {
                LogoView().shadow(radius: 10)
                Spacer()
            }
        }
        // experimenting with the new iOS15 view modifier instead of using the AlertItem
        .alert(Text("Locations Error"), isPresented: $showAlert) {
                      Button("Ok", role: .cancel) { }
                  } message: {
                      Text("Unable to retrieve locations at this time. \n Please try again.")
                  }
        .onAppear {
            CloudKitManager.getLocations { result in
                switch result {
                    // getting back an array of locations
                case .success(let locations):
                    Logger.locationMapView.info("\(locations)")
                case .failure(let error):
                    showAlert = true
                    Logger.locationMapView.error("\(error.localizedDescription)")
                }
            }
        }
    }
}

struct LogoView: View {
    var body: some View {
        Image("ddg-map-logo")
            .resizable()
            .scaledToFit()
            .frame(height: 70)
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}
