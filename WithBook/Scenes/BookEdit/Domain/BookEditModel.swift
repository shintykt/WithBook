//
//  BookEditModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/25.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

protocol BookEdit {
    func validate(_ title: String?) -> Driver<Bool>
}

struct BookEditModel: BookEdit {
    private let user: User = .shared
    
    func validate(_ title: String?) -> Driver<Bool> {
        guard let title = title else { return .just(false) }
        return .just(!title.isEmpty)
    }
}
