//
//  BookListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol BookList {
    func fetchBooks(completion: @escaping ([Book]) -> Void)
    func remove(_ book: Book)
}

struct BookListModel: BookList {
    func fetchBooks(completion: @escaping ([Book]) -> Void) {
        User.shared.fetchBooks { books in
        guard let books = books else { return }
            completion(books)
        }
    }
    
    func remove(_ book: Book) {
        User.shared.remove(book)
    }
}
