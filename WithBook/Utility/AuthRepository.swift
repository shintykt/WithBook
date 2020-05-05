//
//  AuthRepository.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/05/05.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseAuth
import RxSwift

protocol Authorization {
    func authorize(_ email: String, _ password: String) -> Observable<Result<Void, AuthError>>
}

protocol AuthReference {
    var userId: String? { get }
}

enum AuthError: Error {
    case invalidIdAndPassword
}

struct AuthRepository: Authorization {
    func authorize(_ email: String, _ password: String) -> Observable<Result<Void, AuthError>> {
        return Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password ) { authResult, error in
                if let error = error { print(error) }
                guard authResult?.user != nil else { observer.onNext(.failure(.invalidIdAndPassword)); return }
                observer.onNext(.success(()))
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

extension AuthRepository: AuthReference {
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }
}
