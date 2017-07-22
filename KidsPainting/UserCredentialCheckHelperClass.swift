//
//  UserCredentialCheckHelperClass.swift
//  KidsPainting
//
//  Created by emily on 2017-07-11.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//
import UIKit
import Foundation
import FirebaseStorage

func checkIfCorrect(email: String)-> Bool{
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}

/*
 Regex explanation. The regex is used to see if a string match the requirement of the password
 In this particular case the password need to have as follow
 two uppercase letters.
 one special case letter.
 two digits.
 three lowercase letters.
 length 8.
 ^                         Start anchor
 (?=.*[A-Z].*[A-Z])        Ensure string has two uppercase letters.
 (?=.*[!@#$&*])            Ensure string has one special case letter.
 (?=.*[0-9].*[0-9])        Ensure string has two digits.
 (?=.*[a-z].*[a-z].*[a-z]) Ensure string has three lowercase letters.
 .{8}                      Ensure string is of length 8.
 $                         End anchor.
 
 This will change to define the password strength
 */

//  (?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z].{8,}$)
func checkStength(password: String) -> Bool{
    return password.range(of: "^.{8,}$", options: .regularExpression) != nil
}
/*
    This function is used to store a photo inside the storage section
    The params are the image that will be converted to UIImageJPEGRepresentation
    When the url is downloaded we retrive the url from firebase
 */
func upload(media: UIImage, completion: @escaping (_ url: URL) -> Void) {
    let storageRef = Storage.storage().reference().child("users").child("test.jpg")
    if let imageToUpload = UIImageJPEGRepresentation(media, 1.0){
        storageRef.putData(imageToUpload, metadata: nil) { (backendData, error) in
            if let error = error{
                print("Error while uploading the media, this is the error \(error)")
            }
            if let storageMetaData = backendData{
                if let url = storageMetaData.downloadURL(){
                    completion(url)
                }
            }
        }
    }
}

func downloadUserProfileBy(url: URL, completion: @escaping(_ image: Data) -> Void){
    let storage = Storage.storage()
    print("This is the url in the helper class \(url)")
    let ref = storage.reference(forURL: url.path)
    ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error while downloading the profile picture, this is the error \(error)")
        }
        if let data = data{
            completion(data)
        }
    }
}
//Function that take a string containing the url and an escaping closure that get the image data
func downloadImageFrom(_ urlString: String,completion: @escaping (_ data: Data?) -> Void) {
    guard let url = URL(string: urlString) else{return}
    let urlRequest = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
        if let error = error {
            print("Error while downloading the image from firebase \(error)")
            return
        }
        completion(data)
    }
    task.resume()
}
