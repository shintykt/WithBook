//
//  BookListCell.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import UIKit

final class BookListCell: UICollectionViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    func inject(_ book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        imageView.image = book.image
    }
    
    private func loadNib() {
        let view = R.nib.bookListCell(owner: self)!
        addSubview(view)
    }
}
