//
//  MemoEditModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/14.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxSwift

protocol MemoEdit {
    func validate(_ title: String?) -> Observable<Bool>
    func add(_ memo: Memo, about book: Book) -> Observable<Void>
    func replace(_ memo: Memo, about book: Book) -> Observable<Void>
}

struct MemoEditModel: MemoEdit {
    private let memoRepository: MemoRepository
    
    init(memoRepository: MemoRepository = .init()) {
        self.memoRepository = memoRepository
    }
    
    func validate(_ title: String?) -> Observable<Bool> {
        guard let title = title else { return .just(false) }
        return .just(!title.isEmpty)
    }
    
    func add(_ memo: Memo, about book: Book) -> Observable<Void> {
        return memoRepository.add(memo, about: book)
    }
    
    func replace(_ memo: Memo, about book: Book) -> Observable<Void> {
        return memoRepository.replace(memo, about: book)
    }
}
