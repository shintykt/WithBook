//
//  BookListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxSwift

protocol BookList {
    func listenBooks() -> Observable<[BookListSectionModel]>
    func remove(_ book: Book) -> Observable<Void>
}

final class BookListModel {
    private let bookRepository: BookRepository
    
    init(bookRepository: BookRepository = .init()) {
        self.bookRepository = bookRepository
    }
}

extension BookListModel: BookList {
    func listenBooks() -> Observable<[BookListSectionModel]> {
        return bookRepository.listenBooks().map { books -> [BookListSectionModel] in
            let items = books.map { BookListSectionItem(book: $0) }
            return [BookListSectionModel(model: .normal, items: items)]
        }
    }
    
    func remove(_ book: Book) -> Observable<Void> {
        bookRepository.remove(book)
    }
}
