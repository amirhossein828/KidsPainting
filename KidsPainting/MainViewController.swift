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
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        
        ref.child("posts").observeSingleEvent(of: .value) { (dataSnap : DataSnapshot) in
            let value = dataSnap.value as? NSDictionary
            print(value)
            let ans = value?.allValues as? [[String:Any]]
            for a in ans! {
//                if a[Constant.name] == keyword {
                let item = Item()
                item.author = a["author"] as! String
                item.pathToImage = a["pathToImage"] as! String
//                let key = a["pathToImage"]
                    print(a["author"])
                self.items.append(item)
                
//                }
            }
           self.tableView.reloadData()
        }
        
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
//        let storage = Storage.storage().reference(forURL: "gs://kidspainting-33316.appspot.com")
//        let imageRef = storage.child("posts").child(items[indexPath.row].pathToImage)
//        print(imageRef)
//        
//        imageRef.getData(maxSize: INT64_MAX, completion: { (data, error) in
//            guard error == nil else {
//                print("Error downloading: \(error!)")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                let messageImage = UIImage.init(data: data!, scale: 50)
//                cell.imageViewCell.image = messageImage
//            }
//            
//            
//        }
//        )
        
        cell.fullnameField.text = items[indexPath.row].author
        cell.imageViewCell.downloadImage(from: self.items[indexPath.row].pathToImage!)
//        cell.nameLabel.text = self.user[indexPath.row].fullName
//        cell.userID = self.user[indexPath.row].userID
//        cell.userImage.downloadImage(from: self.user[indexPath.row].imagePath!)
//        checkFollowing(indexPath: indexPath)
        
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
    
    func downloadImage(from imgURL: String!) {
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
