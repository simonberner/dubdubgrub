//
//  PhotoPicker.swift
//  DubDubGrub
//
//  Created by Simon Berner on 14.01.22.
//

import SwiftUI

struct PhotoPicker: UIViewControllerRepresentable {

    @Binding var image: UIImage
    @Environment(\.presentationMode) var presentationMode // https://developer.apple.com/documentation/swiftui/environment
    

    // gets called automatically when we use the PhotoPicker
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // used to communicate with UIKit
    // gets called automatically when we use the PhotoPicker
    func makeCoordinator() -> Coordinator {
        Coordinator(photoPicker: self)
    }

    // The coordinator is the communication pipe between UIKit and SwiftUI
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let photoPicker: PhotoPicker

        init(photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                let compressedImageData = image.jpegData(compressionQuality: 0.1)! // compress by 90%
                photoPicker.image = UIImage(data: compressedImageData)!
            }
            // dismiss the 'Choose' PhotoPicker view
            photoPicker.presentationMode.wrappedValue.dismiss()
        }

    }
}
