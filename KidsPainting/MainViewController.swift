//
//  MainViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-13.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var items = [Item]()
    var resultData : NSData = NSData()
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        
        ref.child("posts").observeSingleEvent(of: .value) { (dataSnap : DataSnapshot) in
            let value = dataSnap.value as? NSDictionary
            print(value)
            let ans = value?.allValues as? [[String:Any]]
            for a in ans! {
                
                let item = Item()
                item.author = a["author"] as! String
                
                item.pathToImage = a["pathToImage"] as! String
                self.items.append(item)
               
                
                
            }
            
                
                self.tableView.reloadData()
                
            
           
        }
        ref.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTableViewCell
        

       
        
        cell.fullNameField.text = self.items[indexPath.row].author
      
        cell.imageViewCell.downloadImage(from: items[indexPath.row].pathToImage)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count ?? 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        items.removeAll()
    }

}



extension UIImageView {
    
    func downloadImage(from imgURL: String!)  {
        
        let url = URLRequest(url: URL(string: imgURL)!)
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
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



