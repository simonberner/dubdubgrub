//
//  DubDubGrubApp.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI

@main
struct DubDubGrubApp: App {

    let locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                // injection the locationManager to all the sub/child views
                .environmentObject(locationManager)
        }
    }
}
