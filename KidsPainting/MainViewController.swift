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
    var itemToDetail : Item? = nil
  
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
            let allAnswer = value?.allValues as? [[String:Any]]
            guard let allAnswerOfPosts = allAnswer else {
                return
            }
            for answer in allAnswerOfPosts {
                
                let item = Item()
                item.author = answer["author"] as! String
                
                item.pathToImage = answer["pathToImage"] as! String
                item.nameOfArticle = answer["nameOfArticle"] as! String
                item.price = Double(answer["price"] as! String)
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
        cell.nameOfArticleCell.text = self.items[indexPath.row].nameOfArticle
        cell.priceCell.text = String(self.items[indexPath.row].price)
      
        cell.imageViewCell.downloadImage(from: items[indexPath.row].pathToImage)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count ?? 0
    }
    
    // - make rows in table view selectable
    // - when one row get selected , go to detail page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         itemToDetail = items[indexPath.row]
        
        performSegue(withIdentifier: "goDetail", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetail" {
            let detailVC = segue.destination as! DetailViewController
            if let itemDetail = self.itemToDetail {
            detailVC.itemFromMain = itemDetail
        }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        items.removeAll()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
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



