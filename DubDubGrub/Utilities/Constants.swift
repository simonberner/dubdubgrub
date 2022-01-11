//
//  Constants.swift
//  DubDubGrub
//
//  Created by Simon Berner on 02.01.22.
//

import Foundation
import UIKit

// Stuff in here for easy access

enum RecordType {
    static let location = "DDGLocation"
    static let profile = "Profile"
}

enum PlaceholderImage {
    // force unwrapping here: I know that they exist
    static let avatar = UIImage(named: "default-avatar")!
    static let square = UIImage(named: "default-square-asset")!
    static let banner = UIImage(named: "default-banner-asset")!
}

enum ImageDimension {
    case square, banner

    // using a computed property on self, instead of the static func and passing in the dimension
    var placeholderImage: UIImage {
        switch self {
        case .square:
            return PlaceholderImage.square
        case .banner:
            return PlaceholderImage.banner
        }
    }

//    static func getPlaceholder(for dimension: ImageDimension) -> UIImage {
//        //        return dimension == .square ? PlaceholderImage.square : PlaceholderImage.banner
//        switch dimension {
//        case .square:
//            return PlaceholderImage.square
//        case .banner:
//            return PlaceholderImage.banner
//        }
//    }
}
