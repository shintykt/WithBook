//
//  BookEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseFirestore
import UIKit

final class Book {
    let id: String
    let createdTime: Date
    var updatedTime: Date?
    var title: String
    var author: String?
    var image: UIImage?
    var memos: [Memo]? = []
    
    init(
        id: String = UUID().uuidString,
        createdTime: Date = .init(),
        updatedTime: Date? = nil,
        title: String = "",
        author: String? = Const.defaultText,
        image: UIImage? = Const.defaultImage
    ) {
        self.id = id
        self.createdTime = createdTime
        self.updatedTime = updatedTime
        self.title = title
        self.author = author ?? Const.defaultText
        self.image = image ?? Const.defaultImage
    }
}

struct BookEntity {
    let documentId: String
    let createdTime: Timestamp
    let updatedTime: Timestamp?
    let title: String
    let author: String?
    let imageURL: String?
    
    init(from document: DocumentSnapshot) throws {
        self.documentId = document.documentID
        self.createdTime = try document.value(forField: "createdTime", type: Timestamp.self)
        self.updatedTime = try? document.value(forField: "updatedTime", type: Timestamp.self)
        self.title = try document.value(forField: "title", type: String.self)
        self.author = try? document.value(forField: "author", type: String.self)
        self.imageURL = try? document.value(forField: "imageURL", type: String.self)
    }
}
