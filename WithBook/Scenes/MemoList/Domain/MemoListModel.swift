//
//  MemoListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol MemoList {
    func fetchMemos(completion: @escaping ([Memo]) -> Void)
    func add(_ memo: Memo, completion: @escaping ([Memo]) -> Void)
    func replace(_ memo: Memo, completion: @escaping ([Memo]) -> Void)
    func remove(_ memo: Memo, completion: @escaping ([Memo]) -> Void)
}

final class MemoListModel {
    private let memoRepository: MemoRepository
    private let book: Book
    private var memos: [Memo] = []
    
    init(book: Book, memoRepository: MemoRepository = .init()) {
        self.book = book
        self.memoRepository = memoRepository
    }
}

extension MemoListModel: MemoList {
    func fetchMemos(completion: @escaping ([Memo]) -> Void) {
        memoRepository.fetchMemos(about: book) { [weak self] memo in
            guard let strongSelf = self else { return }
            strongSelf.memos.append(memo)
            completion(strongSelf.memos)
        }
    }
    
    func add(_ memo: Memo, completion: @escaping ([Memo]) -> Void) {
        memoRepository.add(memo, about: book)
        memos.append(memo)
        completion(memos)
    }
    
    func replace(_ memo: Memo, completion: @escaping ([Memo]) -> Void) {
        memoRepository.replace(memo, about: book)
        guard let targetIndex = memos.firstIndex(where: { $0.id == memo.id }) else { return }
        memos[targetIndex] = memo
        completion(memos)
    }
    
    func remove(_ memo: Memo, completion: @escaping ([Memo]) -> Void) {
        memoRepository.remove(memo, about: book)
        memos.removeAll(where: { $0.id == memo.id })
        completion(memos)
    }
}
