//
//  UploadItemViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-16.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase

class UploadItemViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var uploadImageView: UIImageView!
    var newImage : UIImage?
    var name : String?
    var p : String?
    @IBOutlet weak var nameofArticleField: UITextField!
    
    @IBOutlet weak var priceField: UITextField!
    
    @IBOutlet weak var shareButton: UIButton!
    var activityIndicator = UIActivityIndicatorView()
    // - get it position and color
    // - define it's subview
    // - start it
    // - stop it

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the imageView from prepare method
        if let newImg = newImage {
            self.uploadImageView.image = newImg
        }
        // configuration for activityIndicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == nameofArticleField {
            
                        updateShareButton(articleText: newString, priceText: self.priceField.text ?? "")
        }
        else {
            updateShareButton(articleText: self.nameofArticleField.text ?? "", priceText: newString)
        }
        return true
    }
    
    private func updateShareButton(articleText: String, priceText: String) {
        let enabled = !articleText.isEmpty && !priceText.isEmpty
        shareButton.isEnabled = enabled
        
    }


    
    
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func shareBtn(_ sender: UIButton) {
        
        guard let nameOfArticle = nameofArticleField.text ,
            let price = priceField.text else {
            return
        }
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://kidspainting-33316.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.uploadImageView.image!, 0.1)
        
        let uploadTask = imageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    let feed = ["userID" : uid,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "author" : Auth.auth().currentUser!.displayName!,
                                "postID" : key,
                        "nameOfArticle" : nameOfArticle,
                        "price" : price ] as [String : Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    
                    self.activityIndicator.stopAnimating()
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.dismiss(animated: true, completion: nil)
//                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
            
        }
        
        uploadTask.resume()
  
    }

    

}
