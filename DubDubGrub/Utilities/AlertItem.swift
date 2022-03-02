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
    static let unableToGetLocations = AlertItem(title: "Locations Error ⚠️",
                                                message: "Unable to retrieve locations at this time. \n Please try again.",
                                                buttonText: "OK")

    static let locationRestricted = AlertItem(title: "Locations Restricted ⚠️",
                                                message: "Your location is restricted. This may be due to parental controls.",
                                                buttonText: "OK")

    static let locationDenied = AlertItem(title: "Locations Denied ⚠️",
                                                message: "Dub Dub Grub does not have permission to access your location. To change that go to your phone's Settings > Dub Dub Grub > Location",
                                                buttonText: "OK")

    static let locationDisabled = AlertItem(title: "Locations Disabled ⚠️",
                                                message: "Your phone's location services are disabled. To change that go to your phone's Settings > Privacy > Location Services",
                                                buttonText: "OK")

    static let checkedInCount = AlertItem(title: "Server Error ⚠️",
                                                message: "Unable to get then number of people checked into each location. Please check your internet connection and try again.",
                                                buttonText: "OK")

    //MARK: - ProfileView Errors
    static let invalidProfileForm = AlertItem(title: "Invalid Profile ⚠️",
                                                message: "Profile photo and all fields are required. Your Bio must be <=100 characters.\nCheck and try again",
                                                buttonText: "OK")

    static let noUserRecord = AlertItem(title: "No User Record",
                                                message: "You must log into iCloud on your phone in order to use Dub Dub Grub Profile. Please log in.",
                                                buttonText: "OK")

    static let createProfileSuccess = AlertItem(title: "Profile Created Successfull 🎉!",
                                                message: "Your profile has successfully been created.",
                                                buttonText: "OK")

    static let createProfileFailure = AlertItem(title: "Failed to Create Profile ⚠️",
                                                message: "We were unable to create your profile at this time.\n Please try again later.",
                                                buttonText: "OK")

    static let unableToGetProfile = AlertItem(title: "Unable To Get Your profile ⚠️",
                                                message: "We were unable to get your profile at this time.\n Please try again later.",
                                                buttonText: "OK")

    static let updateProfileSuccess = AlertItem(title: "Profile Updated Successfully 🎉",
                                                message: "Your profile has successfully been updated.",
                                                buttonText: "Great!")

    static let updateProfileFailure = AlertItem(title: "Profile Updated Failed ⚠️",
                                                message: "We were unable to update your profile this time.\n Please try again later.",
                                                buttonText: "OK")

    //MARK: - LocationDetailView Errors
    static let invalidPhoneNumber = AlertItem(title: "Invalid Phone Number ⚠️",
                                                message: "The phone number for the location is invalid. Please look up the phone number yourself.",
                                                buttonText: "OK")
    static let unableToGetCheckInStatus = AlertItem(title: "Server Error ⚠️",
                                                message: "Unable to retrieve checked in status of the current user.\nPlease try again later.",
                                                buttonText: "OK")
    static let checkInOutFailed = AlertItem(title: "Check-in/out failed ⚠️",
                                                message: "We currently can't check you in/out. Please make sure you are singed-in to your iCloud account.",
                                                buttonText: "OK")
    static let unableToGetCheckedInProfiles = AlertItem(title: "Server Error ⚠️",
                                                message: "We are currently unable to get all the users checked into this location.\nPlease try again later.",
                                                buttonText: "OK")

    //MARK: LocationListView
    static let unableToGetAllCheckedInProfiles = AlertItem(title: "Server Error ⚠️",
                                                message: "We are currently unable to get all the users checked into the locations.\nPlease try again later.",
                                                buttonText: "OK")

    //MARK: LocationMapViewModel
    static let didFailOnLocationManager = AlertItem(title: "Location Error ⚠️",
                                                message: "We are currently unable to get all the users checked into the locations.\nPlease try again later.",
                                                buttonText: "OK")
}
