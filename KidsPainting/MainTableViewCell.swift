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
    
    @IBOutlet weak var fullnameField: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
