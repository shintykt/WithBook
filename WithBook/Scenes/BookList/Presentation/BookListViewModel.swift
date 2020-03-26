//
//  BookListViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

final class BookListViewModel {
    private var model: BookList
    
    private var books: Driver<[BookListSectionModel]> {
        return booksRelay.asDriver()
    }
    private let booksRelay = BehaviorRelay<[BookListSectionModel]>(value: [])
        
    init(model: BookList) {
        self.model = model
        fetchBooks()
    }
    
    func fetchBooks() {
        model.fetchBooks { [weak self] books in
            let items = books.map { BookListSectionItem(book: $0) }
            let sectionModel = BookListSectionModel(model: .normal, items: items)
            self?.booksRelay.accept([sectionModel])
        }
    }
    
    func remove(_ book: BookListSectionItem) {
        model.remove(book.book)
        fetchBooks()
    }
}

extension BookListViewModel: ViewModel {
    struct Input {
    }
    
    struct Output {
        let books: Driver<[BookListSectionModel]>
    }
    
    func transform(input: Input) -> Output {
        return Output(books: books)
    }
}
