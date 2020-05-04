//
//  DateExtension.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/05/04.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

extension Date {
    var string: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
