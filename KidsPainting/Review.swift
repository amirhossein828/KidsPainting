//
//  Review.swift
//  KidsPainting
//
//  Created by Masoud Bozorgi on 2017-07-25.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import Foundation
import Firebase

class Review{
    
    var displayName : String
    var reviewString : String
    var reviewDate : Date
    
    init(displayName : String, reviewString : String, reviewDate : Date){
        self.displayName = displayName
        self.reviewString = reviewString
        self.reviewDate = reviewDate
    }
    
}
