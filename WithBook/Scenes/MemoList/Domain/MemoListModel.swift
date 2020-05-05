//
//  MemoListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxSwift

protocol MemoList {
    func listenMemos(about book: Book) -> Observable<[Memo]>
    func remove(_ memo: Memo, about book: Book) -> Observable<Void>
}

struct MemoListModel {
    private let memoRepository: MemoCRUD
    
    init(memoRepository: MemoCRUD = MemoRepository()) {
        self.memoRepository = memoRepository
    }
}

extension MemoListModel: MemoList {
    func listenMemos(about book: Book) -> Observable<[Memo]> {
        return memoRepository.listenMemos(about: book)
    }
    
    func remove(_ memo: Memo, about book: Book) -> Observable<Void> {
        return memoRepository.remove(memo, about: book)
    }
}
