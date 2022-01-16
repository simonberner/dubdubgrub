//
//  AlertItem.swift
//  DubDubGrub
//
//  Created by Simon Berner on 04.01.22.
//

import SwiftUI

struct AlertItem {
    let title: String
    let message: String
    let buttonText: String
}

struct AlertContext {
    //MARK: - MapView Errors
    static let unableToGetLocations = AlertItem(title: "Locations Error",
                                                message: "Unable to retrieve locations at this time. \n Please try again.",
                                                buttonText: "OK")

    static let locationRestricted = AlertItem(title: "Locations Restricted",
                                                message: "Your location is restricted. This may be due to parental controls.",
                                                buttonText: "OK")

    static let locationDenied = AlertItem(title: "Locations Denied",
                                                message: "Dub Dub Grub does not have permission to access your location. To change that go to your phone's Settings > Dub Dub Grub > Location",
                                                buttonText: "OK")

    static let locationDisabled = AlertItem(title: "Locations Disabled",
                                                message: "Your phone's location services are disabled. To change that go to your phone's Settings > Privacy > Location Services",
                                                buttonText: "OK")

    //MARK: - ProfileView Errors
    static let invalidProfileForm = AlertItem(title: "Invalid Profile",
                                                message: "Profile photo and all fields are required. Your Bio must be <=100 characters.\nCheck and try again",
                                                buttonText: "OK")
}
