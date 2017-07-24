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
            for (key, value) in value!{
                print("This is the key \(key)")
                print("This is the value \(value)")
            }
            
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
   
}

/*
 This function is used to store a photo inside the storage section
 The params are the image that will be converted to UIImageJPEGRepresentation
 When the url is downloaded we retrive the url from firebase
 */
func upload(media: UIImage, withName: String, completion: @escaping (_ url: URL) -> Void) {
    let storageRef = Storage.storage().reference().child("users").child("\(withName).jpg")
    if let imageToUpload = UIImageJPEGRepresentation(media, 1.0){
        storageRef.putData(imageToUpload, metadata: nil) { (backendData, error) in
            if let error = error{
                print("Error while uploading the media, this is the error \(error)")
            }
            if let storageMetaData = backendData{
                if let url = storageMetaData.downloadURL(){
                    completion(url)
                }
            }
        }
    }
}

func downloadUserProfileBy(url: URL, completion: @escaping(_ image: Data) -> Void){
    let storage = Storage.storage()
    print("This is the url in the helper class \(url)")
    let ref = storage.reference(forURL: url.path)
    ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error while downloading the profile picture, this is the error \(error)")
        }
        if let data = data{
            completion(data)
        }
    }
}
//Function that take a string containing the url and an escaping closure that get the image data
func downloadImageFrom(_ urlString: String,completion: @escaping (_ data: Data?) -> Void) {
    guard let url = URL(string: urlString) else{return}
    let urlRequest = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
        if let error = error {
            print("Error while downloading the image from firebase \(error)")
            return
        }
        completion(data)
    }
    task.resume()
}

