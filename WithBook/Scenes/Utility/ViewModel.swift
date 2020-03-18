//
//  ViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/24.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
