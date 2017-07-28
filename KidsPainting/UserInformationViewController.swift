//
//  UserInformationViewController.swift
//  KidsPainting
//
//  Created by emily on 2017-07-18.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

extension UserInformationViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        googlePlace = place
        if let location = place.formattedAddress{
            locationTextField.text = location
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

//This protocol is used to take a picture, when the photo is validate by the
//user, the function imagePickerController is called
extension UserInformationViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        //If the image exists extract it and store in a constant
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            //Whe can then assing is to the button
            profilePictureButton.setImage(image, for: .normal)
        }
    }
}

//This protocol is nedded in order to use navigation bar while taking piture
extension UserInformationViewController: UINavigationControllerDelegate{
    
}
//Protocol for the collection data source, in order to manage the table view
extension UserInformationViewController: UICollectionViewDataSource{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if items.count > 0{
            displayEmptyImage = false
            return items.count
        }else{
            displayEmptyImage = true
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as! CustomCellUserItemViewController
        if !displayEmptyImage{
            cell.itemImageView?.downloadImage(from: items[indexPath.row].pathToImage)
        }else{
            cell.itemImageView?.image = UIImage(named: "empty")
        }
        return cell
    }
}

extension UserInformationViewController: UICollectionViewDelegate{
    
}

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
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables    
    var firebaseAuth : Auth!
    var nameIsCorrect = true
    var passwordIsCorrect = true
    var googlePlace: GMSPlace!
    var firebaseDatabaseReference: DatabaseReference!
    var firebaseStorageReference: StorageReference!
    var currentUser: User!
    var imagePicker: UIImagePickerController!
    var items = [Item]()
    var displayEmptyImage = true
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseAuth = Auth.auth()
        firebaseDatabaseReference = Database.database().reference()
        firebaseStorageReference = StorageReference()
        displayUserInformation()
        //Set the delegate and the data source of the table view
        collectionView.delegate = self
        collectionView.dataSource = self
        //Add a target to the textfield
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        getUserItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    //This method is called when the user want to take a new picture
    @IBAction func didProfilePictureButtonTouched(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    /*
     This method is called when the user want to edit the location text field
     The action used to triger the action is onDown
     We set the delegate google place and we present the google place view
     */
    @IBAction func didLocationTextFieldPressed(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    /*
        To save the modification inside firebase
 `  */
    @IBAction func didValidateButtonTouched(_ sender: UIButton) {
        //Save or update the information inside the firebase database
        //UIApplication.shared.beginIgnoringInteractionEvents()
        let uid = Auth.auth().currentUser!.uid
        let userReference = firebaseDatabaseReference.child("users").child(uid)
        updateFirebaseUserInformation()
        if let userInformation = getValueToUpdate(){
            userReference.setValue(userInformation)
        }
    }
    
    /*
        To sign out the user, if sign out successfull then present the login page to user
    */
    @IBAction func didSignOutButtonPressed(_ sender: UIButton) {
        //We need to put this action into a do catch block because error can occure during sign out
        do {
            try firebaseAuth.signOut()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "credentialsViewController") as! CredentialsViewController
            present(vc, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

    //MARK: - Methods
    /*
        Method that fetch information relative to the current user
        and display in textField
    */
    func displayUserInformation(){
        if let user = firebaseAuth.currentUser{
            currentUser = user
            firebaseDatabaseReference.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                //Display the information that are store inside the firebase user object
                self.displayFirebaseUserInformations()
                //Display the information from the database
                let value = snapshot.value as? NSDictionary
                self.locationTextField.text = value?["address"] as? String ?? ""
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    //Display the information relative to the firebase user object
    func displayFirebaseUserInformations(){
        nameTextField.text = currentUser.displayName
        emailTextField.text = currentUser.email
        getDataFromUrl(url: (self.currentUser.photoURL)!, completion: { (data, response, error) in
            if let image = UIImage(data: data!){
                DispatchQueue.main.sync {
                    self.profilePictureButton.setImage(image, for: .normal)
                }
            }
        })
    }
    
    //Update the information of the user, this infos will be modify in the firebase user object
    func updateFirebaseUserInformation(){
        let changeRequest = currentUser.createProfileChangeRequest()
        if let name = nameTextField.text{
            if currentUser.displayName != nameTextField.text{
                changeRequest.displayName = name
            }
        }
        if let password = passwordTextField.text {
            if password.characters.count > 0{
                currentUser.updatePassword(to: password, completion: { (error) in
                    if let error = error{
                        print("Error while updating the password \(error)")
                    }else{
                        print("Password modification successfull")
                    }
                })
            }
        }
        if let email = emailTextField.text {
            if email.characters.count > 0 && currentUser.email != email{
                currentUser.updateEmail(to: email, completion: { (error) in
                    if let error = error{
                        print("Error while updating the email \(error)")
                    }else{
                        print("email modification successfull")
                    }
                })
            }
        }
        //Delete the old profile picture
        let oldProfilePictureReference = firebaseStorageReference.child("users").child(currentUser.uid)
        oldProfilePictureReference.delete { error in
            if let error = error{
                print("Error while deleting user profile image \(error)")
            }else{
                print("User profile image deleted")
            }
        }
        
        //Upload the image into firebase storage and store the url into the user
        if let image = profilePictureButton.imageView?.image{
            upload(media: image, withName: "\(currentUser.uid)/", completion: { (url) in
                print("This is the url for the profile picture of the user \(url)")
                changeRequest.photoURL = url
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("error while adding the user display name and the profile picture url \(error)")
                    } else {
                        print("The user is now up to date")
                        //When the user press validate, we dismiss the current view
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    /*
        Does not take any parameter and return an optional dictionary of type String for the key
        and type optional String for the value
    */
    func getValueToUpdate() -> [String:String?]?{
        if googlePlace != nil{
            return ["address": googlePlace.name, "id": googlePlace.placeID, "latitude": "\(googlePlace.coordinate.latitude)", "longitude": "\(googlePlace.coordinate.longitude)"]
        }else{
            return nil
        }
    }
    
    func getUserItems(){
        firebaseDatabaseReference.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                for (_, values) in value   {
                    if let key = values as? NSDictionary{
                        let item = Item()
                        if self.currentUser.uid == key["userID"] as? String{
                            guard let author = key["author"] as? String,
                                let pathToImage = key["pathToImage"] as? String,
                                let nameOfArticle = key["nameOfArticle"] as? String,
                                let price = key["price"] as? String else {
                                    print("The guard failed to cast values")
                                    return
                            }
                            item.author = author
                            item.pathToImage = pathToImage
                            item.nameOfArticle = nameOfArticle
                            item.price = Double(price)
                            self.items.append(item)
                        }
                    }
                }
            }
            self.collectionView.reloadData()
        })
    }
    /*
     This method is triggered whenever the text of a textfield is modify
     This method must be called only when the user want to edit some value
     Depending on the tag of the textfield we check if the field pass the
     requierement. The methods checkStenght and
     */
    func textFieldDidChange(_ textField: UITextField) {
        //This value define the minimum number of caractere that will be accepted for the user name
        // 5 is the minimum for firebase
        let userNameMinimumValue = 5
        switch textField.tag {
        case 1:
            if let name = nameTextField.text {
                nameIsCorrect = name.characters.count >= userNameMinimumValue
            }
        case 4:
            if let password = passwordTextField.text {
                passwordIsCorrect = checkStength(password: password)
            }
        default:
            print("No field are edited")
        }
        if passwordIsCorrect && nameIsCorrect  {
            validateButton.isEnabled = true
        }else{
            validateButton.isEnabled = false
        }
    }
}
