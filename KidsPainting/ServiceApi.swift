//
//  ServiceApi.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-19.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import Foundation
// Protocol for API implementaion
protocol ServiceApi {
    func getAllItemsFrimFireBaseDataBase(complition : @escaping ([Item]) -> Void)
//    func putItemInFireBaseDataBase()
    func updateRatingOfItem(postKey : String, rating : Float, numOfPeople : Int)
}
