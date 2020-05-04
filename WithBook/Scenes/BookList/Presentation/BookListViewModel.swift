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
    private let model: BookList
    private let disposeBag = DisposeBag()
        
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
            .flatMap { [weak self] _ -> Driver<[BookListSectionModel]> in
                guard let self = self else { return .empty() }
                return self.model.listenBooks()
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        let deleteResult = input.deleteBook
            .flatMap { [weak self] book -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.model.remove(book)
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        return Output(
            books: books,
            deleteResult: deleteResult
        )
    }
}
