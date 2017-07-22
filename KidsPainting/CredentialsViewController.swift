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

//Follow the convention to extends the protocol that are used by the pass

//This protocol is used to take a picture, when the photo is validate by the 
//user, the function imagePickerController is called
extension CredentialsViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        //If the image exists extract it and store in a constant
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            //Whe can then assing is to the button
            profilePictureButton.setImage(image, for: .normal)
        }
    }
}
//This protocol is used for the facebook sign in, the loginButton function is called
//when the process of sign in with facebook is finished

extension CredentialsViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        print("Inside the login button method")
        //If the user could not sign in then we have an error
        if let error = error {
            print("This is the user while sign in with the facebook")
            print(error.localizedDescription)
            return
        }
        //If the user is successfully signed in we store
        if let result = result {
            print("This is the result of the facebook sign in decline permission ? = \(result.declinedPermissions) and autorize \(result.grantedPermissions) is cancelled ?= \(result.isCancelled)")
            //We check if the user give the permission to use is personal info from facebook
            if (result.grantedPermissions != nil){
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                //If yes we then authenticate with facebase using the credential
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print("Error while login to firebase with facebook sign in \(error)")
                        return
                    }
                    // We can now have the firebase user with all is relative data
                    if let user = user {
                        print("This is the user from facebook sign in \(user)")
                        let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // This is not used because we are using a global signOut button
    //This method need to be implemented in orderto comply to the protocol
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}

//Extension for the google sing in protocol
extension CredentialsViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("error while sign in with google \(error)")
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("This is the error while sign in with firebase \(error)")
                return
            }
            // User is signed in
            // ...
            if user != nil{
                            let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "mainPage")
                            self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

//To dispaly Google sign in in page
extension CredentialsViewController: GIDSignInUIDelegate{
    
}

//This protocol is nedded in order to use navigation bar in facebook and google sing page
extension CredentialsViewController: UINavigationControllerDelegate{
    
}


//Extension to hide the keyboard when touch anywhere on the view
extension UIViewController: UIGestureRecognizerDelegate{
    func dismissOnTap() {
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    // If user touched Google sign in view, do not hide the keyboard; just ignor it, so didGoogleSignInButtonPressed will be run
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is GIDSignInButton {
            return false
        }
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
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
    @IBOutlet weak var scrollView: UIScrollView!
    
    
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
        //To hide the keyboard when touch on the view
        self.dismissOnTap()
        //Instanciate the firebse Authentication
        firebaseAuth = Auth.auth()
        //Delegate for google sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Add a target to the TextField, when user enter text on textField the method textFieldDidChange is triggered
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        //Delegate for facebook logIn
        facebookLoginButton.delegate = self
        
        displaySignInMethod(true)
        displayCredentialFields(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Everytime the view is display we check if a user is signed
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            //If the user is sign in then we hide the sign in option
            if user != nil{
                print("The user is not nil")
                self.displaySignInMethod(false)
                self.displayCredentialFields(false)
            //If the user is not sign in then we display the sign in option
            }else{
                self.displaySignInMethod(true)
                self.displayCredentialFields(false)
                self.didButtonSignPressed = false
                self.didButtonLogInPressed = false
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
        //The login manager is used to display the facebook sign in page manualy
        let loginManager = LoginManager()
        //Depending on the result we can define action to take
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
    
    //We check how many time the user push the log in button
    //If its the first  time then we display the email field
    //If its the second time we process to the user log in
    @IBAction func didLogInButtonPressed(_ sender: UIButton) {
        logInButton.isEnabled = false
        signUpButton.isHidden = true
        emailTextField.isHidden = false
        if didButtonLogInPressed {
            logInUser()
        }
        didButtonLogInPressed = true
    }
    
    //If the user dont remember is password we display the email field
    //need to implement the password recovery
    @IBAction func didForgetPasswordButtonPressed(_ sender: UIButton) {
        userNameTextField.isHidden = false
    }
    
    //Same then login we check how many time the sign in button is pressed
    //If its the first time we display the email field
    //If not the first time we call the sign in method
    @IBAction func didSignUpButtonPressed(_ sender: UIButton) {
        logInButton.isHidden = true
        signUpButton.isEnabled = false
        emailTextField.isHidden = false
        didButtonSignPressed = true
        if didButtonSignPressed {
            signInUser()
        }
    }
    
    //If the sign out button is pressed we logout the firebase user
    //And we display again the different option to authenticate
    @IBAction func didSignOutButtonPressed(_ sender: UIButton) {
        do {
            try firebaseAuth.signOut()
            displaySignInMethod(true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    //This method will start the process to take a picture
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
        
        //Regarding of the textfield tag we check if the user filled the field
        //following the requirements
        switch textField.tag {
        case 1:
            if let email = emailTextField.text {
                //If the email is correct then we set the boolean variable to true
                emailIsCorrect = checkIfCorrect(email: email)
            }
        case 2:
            if let password = passwordTextField.text {
                //If the password is correct the set the boolean variable to true
                passwordIsCorrect = checkStength(password: password)
                print(passwordIsCorrect)
            }
        case 3:
            //Same then previous if the user name is correct we set the userName boolean to true
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
        
        //If all the field are correct and the user want to log in then the user can press the sign up button
        if emailIsCorrect && passwordIsCorrect && userNameIsCorrect {
            signUpButton.isEnabled = true
        }else{
            logInButton.isEnabled = true
        }
        // If all the field are correct and the user want to sign in then the user can press the sign up button
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
        //We create the firebase user using the value from the fields
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                print("Something wrong when creating the user")
            }
            //If the user is successfully created using the password and the email
            //We can add the profile picture and the user name
            if let user = user{
                print("The user is added to the database")
                //Check again is the user name and the profile picture are not empty
                if let userDisplayName = self.userNameTextField.text,
                    let image = self.profilePictureButton.imageView?.image {
                    //We create a change request for the newly addes user
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = userDisplayName
                    //Upload the image into firebase storage and store the url into the user
                    upload(media: image, completion: { (url) in
                        print("This is the url for the profile picture of the user \(url)")
                        changeRequest.photoURL = url
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("error while adding the user display name and the profile picture url \(error)")
                            } else {
                                print("The user is now up to date")
                                //Launch the main page
                                let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        })
    }
    
    //Method to log in user using firebase
    func logInUser(){
        //Check if the email and the password are not nil
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else {
                //If nil escape the method
                return
        }
        //If not nill we can not authenticate with fierbase using the email and password
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error while sing in the user by email \(error)")
            }
            //If the log in is successfull we can display the main page
            if user != nil {
                let vc = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "navigationPage")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    //This function take a boolean as a parameter
    //Does not return something
    //This function display or hide some of the field related 
    //to the signIn/logIn optino
    func displaySignInMethod(_ value: Bool){
        signOutButton.isHidden = value
        signUpButton.isHidden = !value
        logInButton.isHidden = !value
        googleSignInButton.isHidden = !value
        facebookLoginButton.isHidden = !value
        forgetPasswordButton.isHidden = !value
    }
    //This function take a boolean as a parameter
    //Does not return something
    //This function display or hide some of the field related
    //to the user information
    func displayCredentialFields(_ value: Bool){
        emailTextField.isHidden = !value
        passwordTextField.isHidden = !value
        userNameTextField.isHidden = !value
        profilePictureButton.isHidden = !value
    }
    
    //Boiller plate code to display the textfield on top of the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}
