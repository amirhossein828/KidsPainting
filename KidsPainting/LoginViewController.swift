//
//  LoginViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-12.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLoginField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func loginBtn(_ sender: UIButton) {
        
        // Check email and password are not empty
        guard emailLoginField.text != "", passwordLoginField.text != "" else {return}
        
        // When a user signs in to your app, pass the user's email address and password to this method
        Auth.auth().signIn(withEmail: emailLoginField.text!,
                           password: passwordLoginField.text!,
                           completion: { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            // Go to main page in other story board
            if user != nil {
                
                let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                // Show new storyboard first controller
                self.present(vc, animated: true, completion: nil)
            }
        })
        
        
    }
}
  


