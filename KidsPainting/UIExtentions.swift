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
    
    func downloadImage(from imgURL: String!)  {
        
        let url = URLRequest(url: URL(string: imgURL)!)
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
