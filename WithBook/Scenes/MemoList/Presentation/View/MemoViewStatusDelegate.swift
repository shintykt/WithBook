//
//  MemoViewMovement.swift
//  WithBook
//
//  Created by shintykt on 2020/02/16.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

protocol MemoViewStatusDelegate: AnyObject {
    func didBecomeDragged()
    func didUpdatePosition(of memoView: MemoView, to center: CGPoint)
    func didBecomeRemoved()
    func didResetPosition()
}
