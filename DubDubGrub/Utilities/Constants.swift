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
    static let profile = "DDGProfile"
}

enum PlaceholderImage {
    // force unwrapping here: I know that they exist
    static let avatar = UIImage(named: "default-avatar")!
    static let square = UIImage(named: "default-square-asset")!
    static let banner = UIImage(named: "default-banner-asset")!
}

enum ImageDimension {
    case square, banner, avatar

    // using a computed property on self, instead of the static func and passing in the dimension
    var placeholderImage: UIImage {
        switch self {
        case .square:
            return PlaceholderImage.square
        case .banner:
            return PlaceholderImage.banner
        case .avatar:
            return PlaceholderImage.avatar
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

enum DeviceTypes {

    // helper to get the screen size of the device screen
    enum ScreenSize {
        static let width = UIScreen.main.bounds.width
        static let height = UIScreen.main.bounds.height
        static let maxLength = max(ScreenSize.width, ScreenSize.height)
    }

    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale

    // IF idiom is a .phone AND the maxLength is 667 points AND the nativeScale is equal to scale THEN it is an iPhone8Standard
    // checkout: https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    static let isiPhone8Standard = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
}
