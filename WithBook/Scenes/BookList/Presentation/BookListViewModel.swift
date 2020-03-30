//
//  BookListViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

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
        model.fetchBooks { [weak self] sectionModels in
            self?.booksRelay.accept(sectionModels)
        }
    }
    
    func add(_ item: BookListSectionItem) {
        model.add(item) { [weak self] sectionModels in
            self?.booksRelay.accept(sectionModels)
        }
    }
    
    func replace(_ item: BookListSectionItem) {
        model.replace(item) { [weak self] sectionModels in
            self?.booksRelay.accept(sectionModels)
        }
    }
    
    func remove(_ item: BookListSectionItem) {
        model.remove(item) { [weak self] sectionModels in
            self?.booksRelay.accept(sectionModels)
        }
    }
}

extension BookListViewModel: ViewModel {
    struct Input {}
    
    struct Output {
        let books: Driver<[BookListSectionModel]>
    }
    
    func transform(input: Input) -> Output {
        return Output(books: books)
    }
}
