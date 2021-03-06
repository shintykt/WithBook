//
//  BookEditModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/25.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxSwift

protocol BookEdit {
    func validate(_ title: String?) -> Observable<Bool>
    func add(_ book: Book) -> Observable<Void>
    func replace(_ book: Book) -> Observable<Void>
}

struct BookEditModel {
    private let bookRepository: BookCRUD
    
    init(bookRepository: BookCRUD = BookRepository()) {
        self.bookRepository = bookRepository
    }
}

extension BookEditModel: BookEdit {
    func validate(_ title: String?) -> Observable<Bool> {
        guard let title = title else { return .just(false) }
        return .just(!title.isEmpty)
    }
    
    func add(_ book: Book) -> Observable<Void> {
        return bookRepository.add(book)
    }
    
    func replace(_ book: Book) -> Observable<Void> {
        return bookRepository.replace(book)
    }
}
