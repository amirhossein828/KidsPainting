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
    var likes: Int!
    var pathToImage: String!
    var imageData: NSData!
    var userID: String!
    var postID: String!
    
    var peopleWhoLike: [String] = [String]()
}
