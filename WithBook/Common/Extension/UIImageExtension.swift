//
//  UIImageExtension.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/03/29.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

extension UIImage {
    var compressedJpegData: Data {
        guard let data = jpegData(compressionQuality: Const.imageCompressionRate) else { return Data() }
        return data
    }
}
