//
//  MemoListViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

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
        model.fetchMemos { [weak self] memos in
            self?.memosRelay.accept(memos)
        }
    }
    
    func add(_ memo: Memo) {
        model.add(memo) { [weak self] memos in
            self?.memosRelay.accept(memos)
        }
    }
    
    func replace(_ memo: Memo) {
        model.replace(memo) { [weak self] memos in
            self?.memosRelay.accept(memos)
        }
    }
    
    func remove(_ memo: Memo) {
        model.remove(memo) { [weak self] memos in
            self?.memosRelay.accept(memos)
        }
    }
}

extension MemoListViewModel: ViewModel {
    struct Input {}
    
    struct Output {
        let memos: Driver<[Memo]>
    }
    
    func transform(input: Input) -> Output {
        return Output(memos: memos)
    }
}

