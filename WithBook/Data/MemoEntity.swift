//
//  MemoEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

final class Memo {
    let id: String
    let createDate: Date
    var updateDate: Date?
    var title: String
    var text: String
    var imageData: Data
    var imageName: String {
        return "\(id).jpg"
    }
    var pages: [Int]?
    
    init(
        id: String = UUID().uuidString,
        createDate: Date = Date(),
        updateDate: Date? = nil,
        title: String,
        text: String = Const.defaultText,
        imageData: Data = Const.defaultImage.compressedJpegData,
        pages: [Int]? = nil
    ) {
        self.id = id
        self.createDate = createDate
        self.updateDate = updateDate
        self.title = title
        self.text = text
        self.imageData = imageData
        self.pages = pages
    }
}
