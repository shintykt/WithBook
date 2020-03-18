//
//  SignInViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/15.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

struct SignInViewModel {
    private let model: SignIn
    
    init(model: SignIn) {
        self.model = model
    }
}

extension SignInViewModel: ViewModel {
    struct Input {
        let id: Driver<String>
        let password: Driver<String>
    }
    
    struct Output {
        let canTapSignIn: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let canTapSignIn = Driver
            .combineLatest(input.id, input.password)
            .flatMap { (id, password) -> Driver<Bool> in
                return self.model.validate(id, password)
            }
        
        return Output(canTapSignIn: canTapSignIn)
    }
}
