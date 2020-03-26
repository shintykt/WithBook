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
    private let user: User = .shared
    
    func fetchBooks(completion: @escaping ([Book]) -> Void) {
        user.fetchBooks { books in
            completion(books)
        }
    }
    
    func remove(_ book: Book) {
        user.remove(book)
    }
}
