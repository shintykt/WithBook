//
//  BookListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol BookList {
    func fetchBooks() -> [Book]?
    func remove(_ book: Book)
}

struct BookListModel: BookList {
    func fetchBooks() -> [Book]? {
        return User.shared.fetchBooks()
    }
    
    func remove(_ book: Book) {
        User.shared.remove(book)
    }
}
