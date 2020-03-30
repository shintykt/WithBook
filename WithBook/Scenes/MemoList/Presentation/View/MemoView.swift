//
//  MemoView.swift
//  WithBook
//
//  Created by shintykt on 2020/02/16.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

final class MemoView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var createDateLabel: UILabel!
    @IBOutlet private weak var updateDateLabel: UILabel!
    
    private var originalCenter: CGPoint!
    private var originalPoint: CGPoint = .zero
    private var xFromCenter: CGFloat = 0.0
    private var yFromCenter: CGFloat = 0.0
    
    weak var delegate: MemoViewStatusDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setUpUI()
    }
    
    convenience init(memo: Memo) {
        let frame = CGRect(origin: .zero, size: CGSize(width: 340, height: 450))
        self.init(frame: frame)
        
        titleLabel.text = memo.title
        textView.text = memo.text
        imageView.image = memo.imageData.image
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        createDateLabel.text = formatter.string(from: memo.createDate)
        updateDateLabel.text = memo.updateDate != nil ? formatter.string(from: memo.updateDate!) : Const.defaultText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
}

// MARK: - UI初期設定

private extension MemoView {
    func loadNib() {
        let view = R.nib.memoView(owner: self)!
        view.frame = bounds
        addSubview(view)
    }
    
    func setUpUI() {
        setUpMemoView()
        executeAppearanceAnimation()
    }
    
    func setUpMemoView() {
        // 画像拡大設定
        
        // ドラッグ認識設定
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(beginDrag))
        addGestureRecognizer(dragRecognizer)
    }
    
    // メモ生成アニメーション
    func executeAppearanceAnimation() {
        // アニメーション前
        alpha = 0.0
        center = createBeforeAnimationCenter()
        transform = createBeforeAnimationTransform()
        
        // アニメーション後
        UIView.animate(withDuration: 1.0) { 
            self.alpha = 1.0
            self.center = self.createAfterAnimationCenter()
            self.originalCenter = self.center
            self.transform = self.createAfterAnimationTransform()
        }
    }
    
    // メモ生成アニメーション前の位置
    func createBeforeAnimationCenter() -> CGPoint {
        let beforeAnimationX: CGFloat = CGFloat.random(in: -300 ... 300)
        let beforeAnimationY: CGFloat = CGFloat.random(in: 300 ... 600)
        let beforeAnimationCenter = CGPoint(x: beforeAnimationX, y: beforeAnimationY)
        return beforeAnimationCenter
    }
    
    // メモ生成アニメーション後の位置
    func createAfterAnimationCenter() -> CGPoint {
        let screenCenter = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2
        )
        let afterAnimationX = CGFloat.random(in: -10 ... 10)
        let afterAnimationY = CGFloat.random(in: -10 ... 10)
        let afterAnimationCenter = CGPoint(
            x: screenCenter.x + afterAnimationX,
            y: screenCenter.y + afterAnimationY
        )
        return afterAnimationCenter
    }
    
    // メモ生成アニメーション前の傾き
    func createBeforeAnimationTransform() -> CGAffineTransform {
        let beforeAnimationAngle = CGFloat.random(in: -90 ... 90) * .pi / 180
        let beforeAnimationTransform = CGAffineTransform(rotationAngle: beforeAnimationAngle)
        let beforeAnimationScale: CGFloat = 1.0
        beforeAnimationTransform.scaledBy(x: beforeAnimationScale, y: beforeAnimationScale)
        return beforeAnimationTransform
    }
    
    // メモ生成アニメーション後の傾き
    func createAfterAnimationTransform() -> CGAffineTransform {
        let afterAnimationAngle = CGFloat.random(in: -5 ... 5) * .pi / 180 * 0.25
        let afterAnimationTransform = CGAffineTransform(rotationAngle: afterAnimationAngle)
        let afterAnimationScale: CGFloat = 1.0
        afterAnimationTransform.scaledBy(x: afterAnimationScale, y: afterAnimationScale)
        return afterAnimationTransform
    }
}

// MARK: - タッチ処理

private extension MemoView {
    // ドラッグ時の処理
    @objc func beginDrag(_ sender: UIPanGestureRecognizer) {
        // ドラッグ後の位置を取得
        let afterDragPoint = sender.translation(in: self)
        xFromCenter = afterDragPoint.x
        yFromCenter = afterDragPoint.y
        
        switch sender.state {
        case .began: executeDragBeganAction() // ドラッグ開始時の処理
        case .changed: executeDragChangedAction() // ドラッグ中の処理
        case .cancelled, .ended: executeDragEndedAction(for: sender) // ドラッグ終了時の処理
        default: return
        }
    }
    
    func executeDragBeganAction() {
        // ドラッグ開始時の位置
        originalPoint = CGPoint(
            x: center.x - xFromCenter,
            y: center.y - yFromCenter
        )
        
        delegate?.didBecomeDragged()
    }
    
    func executeDragChangedAction() {
        // メモの位置を更新
        let afterDragCenterX = originalPoint.x + xFromCenter
        let afterDragCenterY = originalPoint.y + yFromCenter
        center = CGPoint(x: afterDragCenterX, y: afterDragCenterY)
        
        delegate?.didUpdatePosition(of: self, to: center)
    }
    
    func executeDragEndedAction(for sender: UIPanGestureRecognizer) {
        // ドラッグ速度を取得
        let dragVerocity = sender.velocity(in: self)
        
        // 左右どちらかへ移動させるかを判定
        let screeenWidth = UIScreen.main.bounds.width
        let shouldBecomeHiddenToLeft = xFromCenter < -(screeenWidth * 2/3)
        let shouldBecomeHiddenToRight = xFromCenter > screeenWidth * 2/3
        
        // 判定結果に応じた処理
        if shouldBecomeHiddenToLeft {
            executeDisappearanceAnimation(withVerocity: dragVerocity)
        } else if shouldBecomeHiddenToRight {
            executeDisappearanceAnimation(withVerocity: dragVerocity, toLeft: false)
        } else {
            resetPotion()
        }
        
        // ドラッグ開始時の位置をリセット
        originalPoint = .zero
        xFromCenter = 0.0
        yFromCenter = 0.0
    }
    
    // メモ削除アニメーション
    func executeDisappearanceAnimation(withVerocity verocity: CGPoint, toLeft: Bool = true) {
        // スワイプ後の予定位置
        let afterHiddenX = UIScreen.main.bounds.width * 2
        let afterHiddenCenterX = toLeft ? -afterHiddenX : afterHiddenX
        let afterHiddenCenterY = verocity.y
        let afterHiddenCenter = CGPoint(x: afterHiddenCenterX, y: afterHiddenCenterY)
        
        // スワイプアニメーション
        UIView.animate(
            withDuration: Const.animationDuration,
            animations: {
                self.center = afterHiddenCenter
            }, completion: { [weak self] _ in
                self?.delegate?.didBecomeRemoved()
                self?.removeFromSuperview()
        })
    }
    
    // メモの位置をリセット
    func resetPotion() {
        UIView.animate(withDuration: Const.animationDuration) {
            self.center = self.originalCenter
        }
        delegate?.didResetPosition()
    }
}
