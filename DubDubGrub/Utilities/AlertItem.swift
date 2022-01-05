//
//  AlertItem.swift
//  DubDubGrub
//
//  Created by Simon Berner on 04.01.22.
//

import SwiftUI

// note: with the coming of iOS15, the Alert struct got deprecated!
// instead we should now use View modifiers like: .alert(_:isPresented:presenting:actions:message:)
//TODO: but how are we going to write these in a reusable way, if the same alert is used in different places?
struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    //MARK: - MapView Errors
    static let unableToGetLocations = AlertItem(title: Text("Locations Error"),
                                                message: Text("Unable to retrieve locations at this time. \n Please try again."),
                                                dismissButton: .default(Text("Ok")))
}
