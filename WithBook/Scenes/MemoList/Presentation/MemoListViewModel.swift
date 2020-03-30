//
//  MemoListViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

final class MemoListViewModel {
    private var model: MemoList
    
    private var memos: Driver<[Memo]> {
        return memosRelay.asDriver()
    }
    private let memosRelay = BehaviorRelay<[Memo]>(value: [])
        
    init(model: MemoList) {
        self.model = model
        fetchMemos()
    }
    
    func fetchMemos() {
        var memos: [Memo] = []
        model.fetchMemos { [weak self] memo in
            memos.append(memo)
            self?.memosRelay.accept(memos)
        }
    }
    
    func remove(_ memo: Memo) {
        model.remove(memo)
    }
}

extension MemoListViewModel: ViewModel {
    struct Input {
    }
    
    struct Output {
        let memos: Driver<[Memo]>
    }
    
    func transform(input: Input) -> Output {
        return Output(memos: memos)
    }
}

