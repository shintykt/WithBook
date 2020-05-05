//
//  SignInViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/15.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa

struct SignInViewModel {
    private let model: SignIn
    
    init(model: SignIn) {
        self.model = model
    }
}

extension SignInViewModel: ViewModel {
    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let signInTap: Driver<Void>
    }
    
    struct Output {
        let canTapSignIn: Driver<Bool>
        let signInResult: Driver<Result<Void, AuthError>>
    }
    
    func transform(input: Input) -> Output {
        let canTapSignIn = Driver.combineLatest(input.email, input.password)
            .flatMap { email, password -> Driver<Bool> in
                return self.model.validate(email, password)
                .asDriver(onErrorJustReturn: false)
            }
        
        let signInResult = input.signInTap
            .withLatestFrom(Driver.combineLatest(input.email, input.password))
            .flatMap { email, password -> Driver<Result<Void, AuthError>> in
                return self.model.authorize(email, password)
                    .asDriver(onErrorDriveWith: .empty())
            }
        
        return Output(
            canTapSignIn: canTapSignIn,
            signInResult: signInResult
        )
    }
}
