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

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var items = [Item]()
    var ref: DatabaseReference!

    
    
    //var resultData : NSData = NSData()  //NSData is not used
    fileprivate var _refHandle: DatabaseHandle!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Already set by storyboard
        //self.tableView.delegate = self
        //self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: ------------------------------------------------- TableView initialization methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return number of items in item array, if it does not exist return 0
        return items.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTableViewCell
        
       
        cell.fullNameField.text     = self.items[indexPath.row].author
        cell.nameOfArticleCell.text = self.items[indexPath.row].nameOfArticle
        cell.priceCell.text         = String(self.items[indexPath.row].price)
        
        
        // downloadImage method is implemented in an extention
        cell.imageViewCell.downloadImage(from: items[indexPath.row].pathToImage)
        
        return cell
    }
    
    
    // MARK: Fix cell height to fix appearance cell problem when height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0; //Choose your custom row height
    }
    
    //-----------------------------------------------------------------------------------
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Fetch list of items from firebase backend
        ref = Database.database().reference()
        
        // Access "posts" object in backend if it does not exist
        ref.child("posts").observeSingleEvent(of: .value)
        { (dataSnap : DataSnapshot) in
            
            let value = dataSnap.value as? NSDictionary
            print(value as Any)
            
            let allAnswer = value?.allValues as? [[String:Any]]
            
            guard let allAnswerOfPosts = allAnswer
                else { return }
            
            
            // To prevent duplication item array can be erased here or in viewDidDisappear
//            items.removeAll()
            
            for answer in allAnswerOfPosts
            {
                //------------------------------------------- To remove current user items from list of items
//                if let uid = answer["uid"] as? String{
//                    if uid != Auth.auth().currentUser!.uid{
//                        // TODO: Create Item object to be added in item array
//                    }
//                }
                //-------------------------------------------------------------------------------------------
                
                let item = Item()
                
                item.author = answer["author"] as! String
                item.pathToImage = answer["pathToImage"] as! String
                item.nameOfArticle = answer["nameOfArticle"] as! String
                item.price = Double(answer["price"] as! String)
                
                self.items.append(item)
            }
            self.tableView.reloadData()
        }
        // To prevent crashing app if we leave current view controller which is under observation
        ref.removeAllObservers()
    }

    override func viewDidDisappear(_ animated: Bool) { items.removeAll() }
    
    
}



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



