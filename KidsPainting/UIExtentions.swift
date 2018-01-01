//
//  UIExtentions.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-19.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import Foundation
import UIKit


// downloads image from specified url and put it in UIImageView
extension UIImageView {
    
    func downloadImage(from imgURL: String)  {
        guard let urlForRequest = URL(string: imgURL) else { return  }
         let url = URLRequest(url: urlForRequest)
        let task = URLSession.shared.dataTask(with: url)
        { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
                
            }
        }
        task.resume()
    }
}
/*
 Extension of UIViewController to display a simple alert
 param: String title, display alert title
 String message, display the main message
 */
extension UIViewController{
    func alert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

/*
    This part is a test to see if we can put the indicator inside the UIViewController extension
*/
var activityIndicator = UIActivityIndicatorView()

extension UIViewController{
    func displayActivityIndicator(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }

}
