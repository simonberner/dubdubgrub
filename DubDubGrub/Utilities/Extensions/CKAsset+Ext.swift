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
        let placeholderImage = ImageDimension.getPlaceholder(for: dimension)

        // unwrap the optional fileURL of the CKAsset
        // (self = CKAsset)
        guard let fileUrl = self.fileURL else { return placeholderImage }

        do {
            let data = try Data(contentsOf: fileUrl)
            return UIImage(data: data) ?? placeholderImage
        } catch {
            return placeholderImage
        }
    }

}
