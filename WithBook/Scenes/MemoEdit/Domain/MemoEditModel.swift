//
//  MemoEditModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/14.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

protocol MemoEdit {
    func validate(_ title: String?) -> Driver<Bool>
}

struct MemoEditModel: MemoEdit {
    private let user: User = .shared
    private let book: Book
    
    init(book: Book) {
        self.book = book
    }
    
    func validate(_ title: String?) -> Driver<Bool> {
        guard let title = title else { return .just(false) }
        return .just(!title.isEmpty)
    }
}
