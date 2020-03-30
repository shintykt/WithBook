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
    private var model: BookEdit
    private let disposeBag = DisposeBag()
    
    let mode: BookEditMode
    private let book: Book
    
    init(model: BookEdit, mode: BookEditMode) {
        self.model = model
        self.mode = mode
        switch mode {
        case .adding: book = Book(title: "")
        case .replacing(let book): self.book = book
        }
    }
}

extension BookEditViewModel: ViewModel {
    struct Input {
        let title: Driver<String>
        let author: Driver<String?>
        let completionTrigger: Observable<Void>
    }
    
    struct Output {
        let canTapComplete: Driver<Bool>
        let completionStatus: Observable<Event<Void>>
    }
    
    func transform(input: Input) -> Output {
        input.title
            .drive(onNext: { [weak self] title in
                self?.book.title = title
            })
            .disposed(by: disposeBag)
        
        input.author
            .drive(onNext: { [weak self] author in
                self?.book.author = author ?? Const.defaultText
            })
            .disposed(by: disposeBag)
        
        let canTapComplete = input.title
            .flatMap { title -> Driver<Bool> in
                return self.model.validate(title)
            }
        
        let completionStatus = input.completionTrigger
            .flatMap { _ -> Observable<Event<Void>> in
                switch self.mode {
                case .adding: return self.model.add(self.book).materialize()
                case .replacing: return self.model.replace(self.book).materialize()
                }
            }
        
        return Output(
            canTapComplete: canTapComplete,
            completionStatus: completionStatus
        )
    }
}

extension BookEditViewModel {
    func input(_ image: UIImage) {
        book.imageData = image.compressedJpegData
    }
}
