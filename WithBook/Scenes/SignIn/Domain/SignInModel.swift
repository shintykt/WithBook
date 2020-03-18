//
//  SignInModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/15.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

// TODO: バリデーションのケースが増えた際にエラーハンドリングで使用
//enum SignInError: Error {
//    case invalidIdAndPassword
//}

protocol SignIn {
    func validate(_ id: String?, _ password: String?) -> Driver<Bool>
}

struct SignInModel: SignIn {
    func validate(_ id: String?, _ password: String?) -> Driver<Bool> {
        guard let id = id, let password = password else { return .just(false) }
        return .just(!id.isEmpty && !password.isEmpty)
    }
}
