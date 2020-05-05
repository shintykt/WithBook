//
//  SignInModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/15.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxSwift

protocol SignIn {
    func validate(_ email: String?, _ password: String?) -> Observable<Bool>
    func authorize(_ email: String, _ password: String) -> Observable<Result<Void, AuthError>>
}

struct SignInModel {
    private let authRepository: Authorization
    
    init(authRepository: Authorization = AuthRepository()) {
        self.authRepository = authRepository
    }
}

extension SignInModel: SignIn {
    func validate(_ email: String?, _ password: String?) -> Observable<Bool> {
        guard let email = email, let password = password else { return .just(false) }
        return .just(!email.isEmpty && !password.isEmpty)
    }
    
    func authorize(_ email: String, _ password: String) -> Observable<Result<Void, AuthError>> {
        return authRepository.authorize(email, password)
    }
}
