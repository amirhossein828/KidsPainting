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
