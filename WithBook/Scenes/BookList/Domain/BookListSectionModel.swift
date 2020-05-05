//
//  BookListSectionModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/29.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxDataSources

typealias BookListSectionModel = AnimatableSectionModel<SectionId, BookListSectionItem>

enum SectionId: String, IdentifiableType {
    case normal
    
    var identity: String {
        return rawValue
    }
}

struct BookListSectionItem: Equatable, IdentifiableType {
    let book: Book
    
    var identity: String {
        return book.id
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identity == rhs.identity
    }
}
