//
//  DataExtension.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/03/29.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

extension Data {
    var image: UIImage {
        return UIImage(data: self) ?? Const.defaultImage
    }
}
