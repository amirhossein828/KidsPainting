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
    var itemToDetail : Item? = nil
  
    var resultData : NSData = NSData()
    fileprivate var _refHandle: DatabaseHandle!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        cell.fullNameField.text = self.items[indexPath.row].author
        cell.nameOfArticleCell.text = self.items[indexPath.row].nameOfArticle
        cell.priceCell.text         = String(self.items[indexPath.row].price)
        cell.imageViewCell.downloadImage(from: items[indexPath.row].pathToImage)
        // downloadImage method is implemented in an extention
//        downloadImageFrom(items[indexPath.row].pathToImage) { (dataImage) in
//            if let dataImage = dataImage{
//                cell.imageViewCell.image = UIImage(data:dataImage,scale:1.0)
//            }
//        }
        return cell
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

    
    
    // MARK: Fix cell height to fix appearance cell problem when height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0; //Choose your custom row height
    }
    
    //-----------------------------------------------------------------------------------
    

    override func viewWillAppear(_ animated: Bool) {
        //In order to check if the user is sign in when display the page
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            //If the user is sign in then we hide the sign in option
            if user != nil{
                print("The user is not nil \(user?.email)")
                //If the user is not sign in then we display the sign in option
            }else{
                print("The user is nil")
            }
        }
        
        print("Inside the view will appear")
        // get Info from firebase data base and put in arrayList
        let serviceApi = ItemsServiceApi()
        serviceApi.getAllItemsFrimFireBaseDataBase { (allItems) in
            print("Set the items")
            self.items = allItems
            self.tableView.reloadData()
        }
    }
    override func viewDidDisappear(_ animated: Bool) { items.removeAll() }
    
    
}







