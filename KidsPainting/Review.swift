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
    
    var review : String
    var date : Date
    var writer : String
    var item : Item!      //TODO: Must be complete
    
    init(){
        self.review = "No review"
        self.date = Date()
        self.writer = "No writer"
    }
    
}
