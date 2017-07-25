//
//  UploadItemViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-16.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase


// The UITextFieldDelegate protocol defines methods that you use to manage the editing and validation of text in a UITextField object.
class UploadItemViewController: UIViewController , UITextFieldDelegate{
    
    
    //MARK: Outlets
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var nameofArticleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: UIActivityIndicatorView is like spinner in android
    var activityIndicator = UIActivityIndicatorView()
    // - get it position and color
    // - define it's subview
    // - start it
    // - stop it

    // MARK: Attributes
    var newImage : UIImage?
    var name : String?
    var p : String?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Set the imageView from prepare method
        if let newImg = newImage { self.uploadImageView.image = newImg }
        
        // Configuration for activityIndicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARk: Action methods ----------------------------------------------------------------
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareBtn(_ sender: UIButton)
    {
        guard
            let nameOfArticle = nameofArticleField.text ,
            let price = priceField.text
            
            else { return }
        
        // Start spinner
        activityIndicator.startAnimating()
        
        
        // Stop handling of touch-related events.
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        // Upload the current image to backend database
        
        // 1- Get the current user uid
        let uid = Auth.auth().currentUser!.uid
        
        // 2- Create a reference to backend database
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://kidspainting-33316.appspot.com")
        
        // 3- Create a storage child (posts) with Auto increment ID: storage/posts                                           ?????
        let key = ref.child("posts").childByAutoId().key
        
        // 4- Locate image object in backend DB: storage/posts/uid/key.jpg
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        
        // 5- Convert image format to data format with compresstion rate 0.1
        let data = UIImageJPEGRepresentation(self.uploadImageView.image!, 0.1)
        
        // 6- Upload image to backend database
        let uploadTask = imageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                
                // 7- If there is an error  stop spinner and rsume the handling of touch events
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            // 8- Get the uploaded picture URL
            imageRef.downloadURL(completion: { (url, error) in
                
                // 9- If url to uploaded image exist
                if let url = url {
                    
                    // 10- Make dictionary of "posts" object attributes and corresponding keys in backed
                    let feed =
                        [
                            "userID" : uid,
                            "pathToImage" : url.absoluteString,
                            "likes" : 0,
                            "author" : Auth.auth().currentUser!.displayName!,
                            "postID" : key,
                            "nameOfArticle" : nameOfArticle,
                            "price" : price
                        ] as [String : Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    // 11- Reference to Firebase DB: write data to backend as user object child with uid and userInfo dictionary
                    // This method will add our new post to backend DB
                    ref.child("posts").updateChildValues(postFeed)
                    
                    // 12-  Stop activityIndicator or spinner
                    self.activityIndicator.stopAnimating()
                    
                    // 13- Rsume the handling of touch events
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // 14- Dismisses the view controller that was presented modally by the view controller.
                    self.dismiss(animated: true, completion: nil)
//                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        }
        uploadTask.resume()
    }
    //--------------------------------------------------------------------------------------
    
    
    // We could use this method from UITextFieldDelegate protocol to prevent the user from entering anything but numerical values.
    // Initialize item name and price with an empty string if, the value does not exist to prevent crashing the application
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == nameofArticleField {
            
            updateShareButton(articleText: newString, priceText: self.priceField.text ?? "")
        }
        else {
            updateShareButton(articleText: self.nameofArticleField.text ?? "", priceText: newString)
        }
        return true
    }
    

    
    // Enabble share Btn when item name and price have value
    private func updateShareButton(articleText: String, priceText: String) {
        
        let enabled = !articleText.isEmpty && !priceText.isEmpty
        shareButton.isEnabled = enabled
    }

}
