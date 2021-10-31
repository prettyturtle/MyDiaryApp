//
//  DiaryCell.swift
//  MyDiary
//
//  Created by yc on 2021/10/31.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 3.0
    }
}
