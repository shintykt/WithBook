//
//  MemoEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

final class Memo {
    let id: String
    let createDate: Date
    var updateDate: Date?
    var title: String
    var image: UIImage?
    var text: String?
    var pages: [Int]?
    
    init(title: String, text: String?, image: UIImage?, pages: [Int]?) {
        id = UUID().uuidString
        createDate = Date()
        self.title = title
        self.text = !(text?.isEmpty ?? true) ? text : Const.defaultText
        self.image = image != nil ? image : Const.defaultImage
        self.pages = pages
    }
}
