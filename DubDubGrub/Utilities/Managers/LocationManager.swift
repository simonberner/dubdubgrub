//
//  LocationManager.swift
//  DubDubGrub
//
//  Created by Simon Berner on 06.01.22.
//

import Foundation

// Very similar to a ViewModel
final class LocationManager: ObservableObject {
    @Published var locations: [DDGLocation] = []

    var selectedLocation: DDGLocation?
}
