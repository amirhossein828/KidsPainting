//
//  ItemsServiceApi.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-19.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import Foundation
import Firebase

class ItemsServiceApi : ServiceApi{
    
    //MARK: - Properties
    var items = [Item]()
    var ref: DatabaseReference!
    
    // get Info from firebase data base
    func getAllItemsFrimFireBaseDataBase(complition : @escaping ([Item]) -> Void){
        print("Inside the getAllItems ...")
        // Fetch list of items from firebase backend
        ref = Database.database().reference()
        
        // Access "posts" object in backend if it does not exist
        ref.child("posts").observeSingleEvent(of: .value){ (dataSnap : DataSnapshot) in
            print("inside the observerSingleEvent")
            let value = dataSnap.value as? NSDictionary
            print(value as Any)
            
            let allAnswer = value?.allValues as? [[String:Any]]
            
            guard let allAnswerOfPosts = allAnswer
                else { return }
            
            
            // To prevent duplication item array can be erased here or in viewDidDisappear
            //            items.removeAll()
            
            for answer in allAnswerOfPosts
            {
                //------------------------------------------- To remove current user items from list of items
                //                if let uid = answer["uid"] as? String{
                //                    if uid != Auth.auth().currentUser!.uid{
                //                        // TODO: Create Item object to be added in item array
                //                    }
                //                }
                //-------------------------------------------------------------------------------------------
                
                let item = Item()
                
                item.author = answer["author"] as! String
                item.pathToImage = answer["pathToImage"] as! String
                item.nameOfArticle = answer["nameOfArticle"] as! String
                item.price = Double(answer["price"] as! String)
                
                self.items.append(item)
            }
            complition(self.items)
            
        }
        // To prevent crashing app if we leave current view controller which is under observation
        ref.removeAllObservers()
    
    }
    
    func putItemInFireBaseDataBase(uploadImageView : UIImageView,complition : ((StorageMetadata?, Error?) -> Void)?) {

    }
   
}
