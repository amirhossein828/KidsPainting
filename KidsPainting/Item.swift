//
//  Item.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-13.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import Foundation

class Item: NSObject {
    
    var author: String!
    var pathToImage: String!
    var nameOfArticle: String!
    var price: Double!
    
    
    // Attributes that are not used yet
    var userID: String!
    var postID: String!
    
    var numberOfAvilable: Int!
    var likes: Int!
    var peopleWhoLike: [String] = [String]()
    
}
