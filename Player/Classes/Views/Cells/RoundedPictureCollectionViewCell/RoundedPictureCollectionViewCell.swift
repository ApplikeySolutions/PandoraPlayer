//
//  RoundedPictureCollectionViewCell.swift
//  Player
//
//  Created by Boris Bondarenko on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit

class RoundedPictureCollectionViewCell: UICollectionViewCell {
    
    // MARK: Instance Variables
    
    // MARK: Outlets
    
    @IBOutlet weak var image: UIImageView!
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Custom Initialization
    
    func configure(with image: UIImage?) {
        self.image.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
		self.image.layer.cornerRadius = self.frame.size.width / 2
    }

}
