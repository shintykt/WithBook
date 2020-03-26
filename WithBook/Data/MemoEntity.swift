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
    var image: UIImage
    var text: String
    var pages: [Int]?
    
    init(
        id: String = UUID().uuidString,
        createDate: Date = Date(),
        updateDate: Date? = nil,
        title: String,
        text: String = Const.defaultText,
        image: UIImage = Const.defaultImage,
        pages: [Int]? = nil
    ) {
        self.id = id
        self.createDate = createDate
        self.updateDate = updateDate
        self.title = title
        self.text = text
        self.image = image
        self.pages = pages
    }
}
