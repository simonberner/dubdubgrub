//
//  Logger+Ext.swift
//  DubDubGrub
//
//  Created by Simon Berner on 03.01.22.
//

import OSLog

// see: https://www.avanderlee.com/workflow/oslog-unified-logging/#improved-apis-in-ios-14-and-up
extension Logger {
    // note: the use of instance stored properties are not allowed in extensions
    // but static (global) stored properties are
    private static let subsystem = Bundle.main.bundleIdentifier!

    // Logs the LocationMapView
    static let locationMapView = Logger(subsystem: subsystem, category: "LocationMapView")
}
