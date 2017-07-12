//
//  SignUpViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-12.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var imageField: UIImageView!
    @IBOutlet weak var nextField: UIButton!
    let imagePicker = UIImagePickerController()
    var userStorage: StorageReference!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        let storage = Storage.storage().reference(forURL: "gs://kidspainting-33316.appspot.com")
        
        ref = Database.database().reference()
        userStorage = storage.child("users")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    

    @IBAction func selectBtn(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageField.image = image
            nextField.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextBtn(_ sender: UIButton) {
        // check if all fields are not empty
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confirmPasswordField.text != "" else { return}
        // check for password match
        if passwordField.text == confirmPasswordField.text {
            // Create a new account by passing the new user's email address and password to
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    // Create a new FIRStorageReference pointing to a child object of users
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    // create data for the image in JPEG format
                    let data = UIImageJPEGRepresentation(self.imageField.image!, 0.5)
                    // upload data to the currently specified FIRStorageReference.
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        // retrieve lived download URL
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(er!.localizedDescription)
                            }
                            
                            
                            if let url = url {
                                // make dictionary of our table
                                let userInfo: [String : Any] = ["uid" : user.uid,
                                                                "full name" : self.nameField.text!,
                                                                "urlToImage" : url.absoluteString]
                                // Write data to users Firebase Database location.
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                // go to main page
                                let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "mainPage")
                                
                                self.present(vc, animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                    })
                    
                    uploadTask.resume()
                    
                }
                
                
            })
            
            
            
        } else {
            print("Password does not match")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss the kyboard when the view is tapped on
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

}
