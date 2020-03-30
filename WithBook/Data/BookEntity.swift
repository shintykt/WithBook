//
//  BookEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

final class Book {
    let id: String
    var title: String
    var author: String
    var imageData: Data
    var imageName: String {
        return "\(id).jpg"
    }
    var memos: [Memo]? = []
    
    init(
        id: String = UUID().uuidString,
        title: String,
        author: String = Const.defaultText,
        imageData: Data = Const.defaultImage.compressedJpegData
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.imageData = imageData
    }
}
