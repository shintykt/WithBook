//
//  BookListViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

struct BookListViewModel {
    private let model: BookList
        
    init(model: BookList) {
        self.model = model
    }
}

extension BookListViewModel: ViewModel {
    struct Input {
        let viewDidLoad: Driver<Void>
        let deleteBook: Driver<Book>
    }
    
    struct Output {
        let books: Driver<[BookListSectionModel]>
        let deleteResult: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let books = input.viewDidLoad
            .flatMap { _ -> Driver<[BookListSectionModel]> in
                return self.model.listenBooks()
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        let deleteResult = input.deleteBook
            .flatMap { book -> Driver<Void> in
                return self.model.remove(book)
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        return Output(
            books: books,
            deleteResult: deleteResult
        )
    }
}
