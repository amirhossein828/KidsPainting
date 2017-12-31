//
//  MainTableViewCell.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-13.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var fullNameField: UILabel!
    @IBOutlet weak var nameOfArticleCell: UILabel!
    @IBOutlet weak var priceCell: UILabel!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    override func awakeFromNib() {
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width / 2
    }
}
