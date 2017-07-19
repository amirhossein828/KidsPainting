//
//  CredentialsViewController.swift
//  KidsPainting
//
//  Created by emily on 2017-07-11.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit

extension CredentialsViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profilePictureButton.setImage(image, for: .normal)
        }
    }
}

extension CredentialsViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        print("Inside the login button method")
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if let result = result {
            print(result)
            if (result.grantedPermissions != nil){
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print("Error while login to firebase with facebook sign in \(error)")
                        return
                    }
                    if let user = user {
                        print("This is the user from facebook sign in \(user)")
                        let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}

extension CredentialsViewController : GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if (signIn.currentUser) != nil{
            print("We should move to the next page")
            let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "mainPage")
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension CredentialsViewController: UINavigationControllerDelegate{
    
}

class CredentialsViewController: UIViewController{
    
    //MARK: - IBOutlets
    @IBOutlet weak var applicationLogoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    //MARK: - Variables
    var firebaseAuth : Auth!
    var didButtonSignPressed = false
    var didButtonLogInPressed = false
    var emailIsCorrect = false
    var passwordIsCorrect = false
    var userNameIsCorrect = false
    var imagePicker: UIImagePickerController!
    
    //MARK: - Application Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseAuth = Auth.auth()
        //Set the password field to be replace by start when typed
        passwordTextField.isSecureTextEntry = true
        
        //Add a target to the TextField, when user enter text on textField the method textFieldDidChange is triggered
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        //Delegate for google sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        //Delegate for facebook logIn
        facebookLoginButton.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                print("The user is not nil")
                self.displaySignInMethod(false)
                self.displayCredentialFields(false)
            }else{
                self.displaySignInMethod(true)
                self.displayCredentialFields(false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Button actions
    
    @IBAction func didGoogleSignInButtonPressed(_ sender: GIDSignInButton) {
        print("Click on the google sign in button")
    }
    
    @IBAction func didFacebookLoginButtonPressed(_ sender: FBSDKLoginButton) {
        print("Click on the sign in button")
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( _, _, _):
                print("Logged in!")
            }
        }
    }
    
    
    @IBAction func didLogInButtonPressed(_ sender: UIButton) {
        logInButton.isEnabled = false
        signUpButton.isHidden = true
        emailTextField.isHidden = false
        if didButtonLogInPressed {
            logUser()
        }
        didButtonLogInPressed = true
    }
    
    @IBAction func didForgetPasswordButtonPressed(_ sender: UIButton) {
        userNameTextField.isHidden = false
        passwordTextField.isHidden = false
    }
    
    @IBAction func didSignUpButtonPressed(_ sender: UIButton) {
        logInButton.isHidden = true
        signUpButton.isEnabled = false
        emailTextField.isHidden = false
        didButtonSignPressed = true
        if didButtonSignPressed {
            signInUser()
        }
    }
    
    @IBAction func didSignOutButtonPressed(_ sender: UIButton) {
        do {
            try firebaseAuth.signOut()
            displaySignInMethod(true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func didProfileButtonPressed(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Methods
    /*
        This method is triggered whenever the text of a textfield is modify
        Depending on the tag of the textfield we check if the field pass the 
        requierement. The methods checkStenght and
    */
    func textFieldDidChange(_ textField: UITextField) {
        //This value define the minimum number of caractere that will be accepted for the user name
        // 5 is the minimum for firebase
        let userNameMinimumValue = 5
        
        switch textField.tag {
        case 1:
            if let email = emailTextField.text {
                emailIsCorrect = checkIfCorrect(email: email)
            }
        case 2:
            if let password = passwordTextField.text {
                passwordIsCorrect = checkStength(password: password)
                print(passwordIsCorrect)
            }
        case 3:
            if let userName = userNameTextField.text {
                userNameIsCorrect = userName.characters.count >= userNameMinimumValue
            }
        default:
            print("No field are edited")
        }
        //If email correct then display the password field
        if emailIsCorrect {
            passwordTextField.isHidden = false
        }
        //If the password is correct and it the user want to create an account
        //then we ask for the user name
        if passwordIsCorrect && didButtonSignPressed {
            profilePictureButton.isHidden = false
            userNameTextField.isHidden = false
        }
        
        if emailIsCorrect && passwordIsCorrect && userNameIsCorrect {
            signUpButton.isEnabled = true
        }else{
            logInButton.isEnabled = true
        }
        if emailIsCorrect && passwordIsCorrect && !didButtonSignPressed{
            logInButton.isEnabled = true
        }else{
            logInButton.isEnabled = false
        }
    }
    
    
    
    //This method is called when the user want to create is account
    // We check one more time that the mandatory field are not empty
    func signInUser(){
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print("Something wrong when creating the user")
            }
            if let user = user{
                print("The user is added to the database")
                if let userDisplayName = self.userNameTextField.text {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = userDisplayName
                    if let image = self.profilePictureButton.imageView?.image{
                        upload(media: image, completion: { (url) in
                            print("This is the url for the profile picture of the user \(url)")
                            changeRequest.photoURL = url
                            
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    print("error while adding the user display name and the profile picture url \(error)")
                                } else {
                                    print("The user is now up to date")
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    func logUser(){
        print("Inside the log user ")
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else {
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error while sing in the user by email \(error)")
            }
            if user != nil {
                let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func displaySignInMethod(_ value: Bool){
        signOutButton.isHidden = value
        signUpButton.isHidden = !value
        logInButton.isHidden = !value
        googleSignInButton.isHidden = !value
        facebookLoginButton.isHidden = !value
        forgetPasswordButton.isHidden = !value
    }
    
    func displayCredentialFields(_ value: Bool){
        emailTextField.isHidden = !value
        passwordTextField.isHidden = !value
        userNameTextField.isHidden = !value
        profilePictureButton.isHidden = !value
    }
}
