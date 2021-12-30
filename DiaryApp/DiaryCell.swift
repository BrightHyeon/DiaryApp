//
//  DiaryCell.swift
//  DiaryApp
//
//  Created by HyeonSoo Kim on 2021/12/19.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //    @IBOutlet weak var contentView: UIView! //이렇게 접근해보려했는데 오류남.
    required init?(coder: NSCoder) { //UIView가 스토리보드에서 생성될 때, 이 생성자를 통해 객체가 생성이 됨. 생성자를 호출하여 자신의 contentView에 접근.
        //UIView는 UICollectionViewCell보다 두 단계 높은 클래스.
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0 //셀의 루트뷰에 접근해서 설정???
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}
