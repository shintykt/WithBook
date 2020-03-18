//
//  MemoListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol MemoList {
    func fetchMemos() -> [Memo]?
    func remove(_ memo: Memo)
}

struct MemoListModel: MemoList {
    let book: Book
    
    func fetchMemos() -> [Memo]? {
        return User.shared.fetchMemos(about: book)
    }
    
    func remove(_ memo: Memo) {
        User.shared.remove(memo, about: book)
    }
}
