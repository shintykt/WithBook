//
//  MemoListViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

final class MemoListViewModel {
    private let model: MemoList
    
    init(model: MemoList) {
        self.model = model
    }
}

extension MemoListViewModel: ViewModel {
    struct Input {
        let viewDidLoad: Driver<Void>
        let book: Driver<Book>
        let deleteMemo: Driver<Memo>
    }
    
    struct Output {
        let memos: Driver<[Memo]>
        let deleteResult: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let memos = Driver.combineLatest(input.book, input.viewDidLoad)
            .flatMap { [weak self] book, _ -> Driver<[Memo]> in
                guard let self = self else { return .empty() }
                return self.model.listenMemos(about: book)
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        let deleteResult = Driver.combineLatest(input.book, input.deleteMemo)
            .flatMap { [weak self] book, memo -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.model.remove(memo, about: book)
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        return Output(
            memos: memos,
            deleteResult: deleteResult
        )
    }
}

