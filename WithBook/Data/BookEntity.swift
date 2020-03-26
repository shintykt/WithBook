//
//  BookEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

final class Book {
    let id: String
    var title: String
    var author: String
    var image: UIImage
    var memos: [Memo]? = []
    
    init(
        id: String = UUID().uuidString,
        title: String,
        author: String = Const.defaultText,
        image: UIImage = Const.defaultImage
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.image = image
    }
}
