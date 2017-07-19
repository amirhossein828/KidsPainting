//
//  SignUpViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-12.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase


// We need to conform to two protocols UIImagePickerControllerDelegate, UINavigationControllerDelegate

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var imageField: UIImageView!
    
    @IBOutlet weak var nextField: UIButton!
    
    // Create an instance of UIImagePickerController
    let imagePicker = UIImagePickerController()
    
    
    
    //  Storage # 1 - Create a reference to user storage in backend
    var userStorage: StorageReference!
    
    
    // Reference to backend DB # 1/3
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set UIImagePickerController.deligate to self,
        // because current class is conform to UIImagePickerControllerDelegate and UINavigationControllerDelegate protocols
        imagePicker.delegate = self
        
        
        
        // Storage # 2 - Create a reference to Firebase storage to upload abd download image and other resources
        let storage = Storage.storage().reference(forURL: "gs://kidspainting-33316.appspot.com")
        
        // Reference to backend DB # 2/3: Initialization
        ref = Database.database().reference()
        
        // Storage # 3 - Create an entity of type StorageReference by using storage reference url
        // in our backend storage as a chiled of main storage, and name it as "useres"
        userStorage = storage.child("users")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    //----------------------------------------  Select Photo Btn
    @IBAction func selectBtn(_ sender: UIButton) {
        
        // This line can make UIImagePickerController to be able to edit an image
        imagePicker.allowsEditing = true
        
        // Set UIImagePickerController data source to Photo Library
        imagePicker.sourceType = .photoLibrary
        
        // To present selected photo from Photo library in current view controller
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    
    // This method will be run only when user photo selection is done
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        // Get the selected image from UIImagePickerController and set current page imageField by selected image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageField.image = image
            
            nextField.isHidden = false
        }
        
        // Dismiss the UIImagePickerController at the end when image selection is done
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //----------------------------------------  Next Btn for navigation to main story board
    @IBAction func nextBtn(_ sender: UIButton) {
        
        
        // 1- Check if all fields in SignUp page are not empty
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confirmPasswordField.text != "" else { return }
        
        
        
        // 2- Check for password match in password and confirmPassword Field
        if passwordField.text == confirmPasswordField.text
        {
            
            // 3- Create a new uaer object in backedn  -------------------------------------
            // by passing the new user's email address and password to Firebase
            Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!,
            //------------------------------------------------------------------------------
                
                                   completion:
                // 4- By creating this new user we will have a user or an error
                {(user, error) in
                                    
                    // 5- If there is an error print it
                    if let error = error { print(error.localizedDescription) }
                    
                    
                    
                    
                    // 6- If we hava user object: upload user profile selected picture to Firebase database
                    if let user = user
                    {
                        
                        
                        
                        //15- Change current user to user object we just created to show it in our UI, without going to backend to save some time
                        let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                        changeRequest.displayName = self.nameField.text!
                        changeRequest.commitChanges(completion: nil)
                        //---------------------------------------------------------
                        
                        
                        // 7- Create a child storage for userStorage, so we will have:   storage/users/uid.jpg
                        let imageRef = self.userStorage.child("\(user.uid).jpg")
                        
                        // 8- Convert image format to data format
                        // Firebase can understand Data format, but it has no idea about UIImage, so we have to convert our jpeg to data
                        // 0.5 is compresstion rate, to make picture smaller and easier to upload
                        let data = UIImageJPEGRepresentation(self.imageField.image!, 0.5)
                        
                        // 9- Upload data to: storage/users/uid.jpg
                        let uploadTask = imageRef.putData(data!, metadata: nil, completion:
                        { (metadata, err) in
                            if err != nil
                            {
                                print(err!.localizedDescription)
                            }
                            
                            // 10- Get the uploaded picture URL
                            imageRef.downloadURL(completion:
                                { (url, er) in
                                    if er != nil
                                    {
                                        print(er!.localizedDescription)
                                    }
                                    
                                    //11- If we have url to uploaded profile picture in backend which is the same as user object url
                                    if let url = url
                                    {
                                        // 12- Make dictionary of user object attributes and corresponding keys in backed
                                        let userInfo: [String : Any] = ["uid" : user.uid,
                                                                        "full name" : self.nameField.text!,
                                                                        "urlToImage" : url.absoluteString]
                                        
                                        // 13- Reference to Firebase DB# 3/3: write data to backend as user object child with uid and userInfo dictionary
                                        self.ref.child("users").child(user.uid).setValue(userInfo)
                                        
                                        // 14- Go to main storyboard with identifier: "navigationPage"
                                        let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                                        
                                        self.present(vc, animated: true, completion: nil)
                                    }
                                })
                            })
                        // 16- Triger running completion on putData method
                        uploadTask.resume()
                    }
                })
        } else {
            print("Password does not match")
        }
    }
    
    //17- In Firebase backend we have to activate authentication
    
    //18- In our plist we have to add a line to ask user for permission to access photo library: Privacy - Photo Library Usage Description
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Dismiss the kyboard when the view is tapped on
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

}
