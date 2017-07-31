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
    //var date : Date
    //var item : Item!
    
    init(displayName : String, reviewString : String){
        self.displayName = displayName
        self.reviewString = reviewString
    }
    
}
