//
//  CKAsset+Ext.swift
//  DubDubGrub
//
//  Created by Simon Berner on 10.01.22.
//

import CloudKit
import UIKit

extension CKAsset {

    // convert a CKAsset (external file in CloudKit) into a UIImage with the corresponding dimension
    func convertToUIImage(in dimension: ImageDimension) -> UIImage {
        let placeholderImage = dimension.placeholderImage

        // unwrap the optional fileURL of the CKAsset (self = CKAsset)
        guard let fileUrl = self.fileURL else { return placeholderImage }

        do {
            // get the image data from the file url
            let data = try Data(contentsOf: fileUrl)
            // return the specific image object with the specified data
            return UIImage(data: data) ?? placeholderImage
        } catch {
            return placeholderImage
        }
    }

}
