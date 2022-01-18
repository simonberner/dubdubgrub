//
//  UIImage+Ext.swift
//  DubDubGrub
//
//  Created by Simon Berner on 16.01.22.
//

import UIKit
import CloudKit
import OSLog

extension UIImage {

    func convertToCKAsset() -> CKAsset? {
        // Get the apps base document directory url
        guard let urlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Logger.uiImageExt.error("Document Directory url came back nil!")
            return nil
        }

        // Append some unique identifier for the profile image
        let fileUrl = urlPath.appendingPathComponent("selectedAvatarImage")

        // Compress the image to Data (in memory byte buffer)
        guard let imageData = jpegData(compressionQuality: 0.25) else {
            Logger.uiImageExt.error("Couldn't compress the UIImage to image data!")
            return nil
        }

        do {
            // Write the data to the address
            try imageData.write(to: fileUrl)
            Logger.uiImageExt.info("ImageData written to: \(fileUrl)")
            // Return a CKAsset from the Data at that address
            return CKAsset(fileURL: fileUrl)
        } catch {
            Logger.uiImageExt.error("Couldn't write the imageData to: \(fileUrl)")
            return nil
        }
    }
}
