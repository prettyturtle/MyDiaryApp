//
//  StarCell.swift
//  MyDiary
//
//  Created by yc on 2021/11/03.
//

import UIKit

class StarCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
    }
}
