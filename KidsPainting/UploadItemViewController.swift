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
class UploadItemViewController: UIViewController {
    
    
    //MARK: Outlets
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var nameofArticleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var itemDescriptionField: UITextField!
    //MARK: UIActivityIndicatorView is like spinner in android
    var activityIndicator = UIActivityIndicatorView()
    // - get it position and color
    // - define it's subview
    // - start it
    // - stop it

    // MARK: Attributes
    var newImage : UIImage?

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Set the imageView from prepare method
        if let newImg = newImage { self.uploadImageView.image = newImg }
        
        // Configuration for activityIndicator
        configurationForactivityIndicator()
        // hide tabBar
        self.tabBarController?.tabBar.isHidden = true
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
            let price = priceField.text,
            let descrip = self.itemDescriptionField.text
            else { return }
        let webSrevice = ItemsServiceApi()
        // upload item
        webSrevice.uploadItem(nameOfArticle: nameOfArticle, price: price, uid: Auth.auth().currentUser!.uid, image: self.uploadImageView.image!, itemDescription: descrip) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    //--------------------------------------------------------------------------------------
    

    // Enabble share Btn when item name and price have value
        func updateShareButton(articleText: String, priceText: String) {
        
        let enabled = !articleText.isEmpty && !priceText.isEmpty
        shareButton.isEnabled = enabled
    }
    
    // Configuration for activityIndicator
    func configurationForactivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }

}

extension UploadItemViewController : UITextFieldDelegate{
    
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
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true, viewController: self)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false, viewController: self)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
}
