//
//  ImageSaver.swift
//  InstaFilter
//
//  Created by Peter Hartnett on 3/17/22.
//

import Foundation
import SwiftUI

//class ImageSaver: NSObject {
//    func writeToPhotoAlbum(image: UIImage) {
//        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
//    }
//
//    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        print("Save finished!")
//    }
//}


import UIKit

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveComplete), nil)
    }

    @objc func saveComplete(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
