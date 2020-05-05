//
//  FirebaseExtension.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/05/04.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseFirestore

extension DocumentSnapshot {
    func value<T>(forField field: String, type: T.Type) throws -> T {
        guard let value = get(field) as? T else {
            throw NSError(
                domain: FirestoreErrorDomain,
                code: FirestoreErrorCode.notFound.rawValue,
                userInfo: ["path": reference.path, "field": field]
            )
        }
        return value
    }
}
