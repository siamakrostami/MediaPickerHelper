//
//  MediaPickerTypes.swift
//  MediaPickerHelper
//
//  Created by Siamak Rostami on 8/8/21.
//

import Foundation

enum MediaPickerTypes : String{
    case
        Camera = "Camera",
        Library = "Library",
        Files = "Files",
        Remove = "Remove"
        }

enum MediaPickerExtensions{
    case
        Video , Audio , Document , Image , Unsopported
}
