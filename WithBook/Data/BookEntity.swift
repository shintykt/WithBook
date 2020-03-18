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
    var author: String?
    var image: UIImage?
    var memos: [Memo]? = []
    
    init(title: String, author: String?, image: UIImage?) {
        id = UUID().uuidString
        self.title = title
        self.author = !(author?.isEmpty ?? true) ? author : Const.defaultText
        self.image = image != nil ? image : Const.defaultImage
    }
}
