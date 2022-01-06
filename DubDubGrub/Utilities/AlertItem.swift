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
}
