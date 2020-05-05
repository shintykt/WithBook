//
//  BookEditViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/25.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

enum BookEditMode {
    case adding
    case replacing(Book)
}

final class BookEditViewModel {
    private let model: BookEdit
    private let disposeBag = DisposeBag()
    
    private var book: Book!
    
    init(model: BookEdit) {
        self.model = model
    }
}

extension BookEditViewModel: ViewModel {
    struct Input {
        let mode: Driver<BookEditMode>
        let title: Driver<String>
        let author: Driver<String?>
        let image: Driver<UIImage>
        let completeTap: Driver<Void>
    }
    
    struct Output {
        let book: Driver<Book>
        let canTapComplete: Driver<Bool>
        let completeResult: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        input.title
            .drive(onNext: { [weak self] title in
                guard let book = self?.book else { return }
                book.title = title
            })
            .disposed(by: disposeBag)
        
        input.author
            .drive(onNext: { [weak self] author in
                guard let book = self?.book else { return }
                book.author = author ?? Const.defaultText
            })
            .disposed(by: disposeBag)
        
        input.image
            .drive(onNext: { [weak self] image in
                guard let book = self?.book else { return }
                book.image = image
            })
            .disposed(by: disposeBag)
        
        let book = input.mode
            .map { [weak self] mode -> Book in
                guard let self = self else { return Book() }
                
                switch mode {
                case .adding:
                    self.book = Book()
                case .replacing(let book):
                    self.book = book
                }
                
                return self.book
            }
        
        let canTapComplete = input.title
            .flatMap {  [weak self] title -> Driver<Bool> in
                guard let self = self else { return .just(false) }
                return self.model.validate(title)
                    .asDriver(onErrorJustReturn: false)
            }
        
        let completeResult = Driver.combineLatest(input.mode, input.completeTap)
            .flatMap { [weak self] mode, _ -> Driver<Void> in
                guard let self = self else { return .empty() }
                
                switch mode {
                case .adding:
                    return self.model.add(self.book)
                        .asDriver(onErrorDriveWith: .empty())
                case .replacing:
                    return self.model.replace(self.book)
                        .asDriver(onErrorDriveWith: .empty())
                }
            }
        
        return Output(
            book: book,
            canTapComplete: canTapComplete,
            completeResult: completeResult
        )
    }
}
