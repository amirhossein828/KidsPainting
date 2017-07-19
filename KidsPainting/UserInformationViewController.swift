//
//  UserInformationViewController.swift
//  KidsPainting
//
//  Created by emily on 2017-07-18.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit

class UserInformationViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var nameImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Variables
    var nameIsCorrect = false
    var emailIsCorrect = false
    var passwordIsCorrect = false
    
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    
    @IBAction func didProfilePictureButtonTouched(_ sender: UIButton) {
    }
    
    
    
    @IBAction func didValidateButtonTouched(_ sender: UIButton) {
    }
    
    // MARK: - Methods
    
    //MARK: - Methods
    /*
     This method is triggered whenever the text of a textfield is modify
     Depending on the tag of the textfield we check if the field pass the
     requierement. The methods checkStenght and
     */
//    func textFieldDidChange(_ textField: UITextField) {
//        //This value define the minimum number of caractere that will be accepted for the user name
//        // 5 is the minimum for firebase
//        let userNameMinimumValue = 5
//        
//        switch textField.tag {
//        case 1:
//            if let name = nameTextField.text {
//                nameIsCorrect = name.characters.count => userNameMinimumValue
//            }
//        case 2:
//            if let password = passwordTextField.text {
//                passwordIsCorrect = checkStength(password: password)
//                print(passwordIsCorrect)
//            }
//        case 3:
//            if let userName = userNameTextField.text {
//                userNameIsCorrect = userName.characters.count >= userNameMinimumValue
//            }
//        default:
//            print("No field are edited")
//        }
//        //If email correct then display the password field
//        if emailIsCorrect {
//            passwordTextField.isHidden = false
//        }
//        //If the password is correct and it the user want to create an account
//        //then we ask for the user name
//        if passwordIsCorrect && didButtonSignPressed {
//            profilePictureButton.isHidden = false
//            userNameTextField.isHidden = false
//        }
//        
//        if emailIsCorrect && passwordIsCorrect && userNameIsCorrect {
//            signUpButton.isEnabled = true
//        }else{
//            logInButton.isEnabled = true
//        }
//        if emailIsCorrect && passwordIsCorrect && !didButtonSignPressed{
//            logInButton.isEnabled = true
//        }else{
//            logInButton.isEnabled = false
//        }
 //   }
}
