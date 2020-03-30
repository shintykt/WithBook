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
    private let user: User = .shared
    private let book: Book
    private var memos: [Memo] = []
    
    init(book: Book) {
        self.book = book
    }
}

extension MemoListModel: MemoList {
    func fetchMemos(completion: @escaping ([Memo]) -> Void) {
        user.fetchMemos(about: book) { [weak self] memo in
            guard let strongSelf = self else { return }
            strongSelf.memos.append(memo)
            completion(strongSelf.memos)
        }
    }
    
    func add(_ memo: Memo, completion: @escaping ([Memo]) -> Void) {
        user.add(memo, about: book)
        memos.append(memo)
        completion(memos)
    }
    
    func replace(_ memo: Memo, completion: @escaping ([Memo]) -> Void) {
        user.replace(memo, about: book)
        guard let targetIndex = memos.firstIndex(where: { $0.id == memo.id }) else { return }
        memos[targetIndex] = memo
        completion(memos)
    }
    
    func remove(_ memo: Memo, completion: @escaping ([Memo]) -> Void) {
        user.remove(memo, about: book)
        memos.removeAll(where: { $0.id == memo.id })
        completion(memos)
    }
}
