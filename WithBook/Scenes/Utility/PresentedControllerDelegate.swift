//
//  PresentedControllerDelegate.swift
//  WithBook
//
//  Created by shintykt on 2020/02/25.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol PresentedControllerDelegate: AnyObject {
    // iOS13以降dismissしても表示元のviewWillAppearが呼ばれないため追加
    func presentedControllerWillDismiss()
}
