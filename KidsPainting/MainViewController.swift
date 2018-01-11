//
//  MainViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-13.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class MainViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var items = [Item]()
    var ref: DatabaseReference!
    var user : User!

    
    
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
    
    @IBAction func didProfileButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let VC1 = storyboard.instantiateViewController(withIdentifier: "UserInformationViewController") as! UserInformationViewController
        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.show(navController, sender:true)
    }
    
    
    // MARK: ------------------------------------------------- TableView initialization methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return number of items in item array, if it does not exist return 0
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTableViewCell
        
        cell.fullNameField.text     = self.items[indexPath.row].author
        cell.nameOfArticleCell.text = self.items[indexPath.row].nameOfArticle
        cell.priceCell.text         = String(Int(self.items[indexPath.row].price))
        let imagePthUrl = URL(string: items[indexPath.row].pathToImage)
        cell.imageViewCell.sd_setImage(with: imagePthUrl)
        cell.profilePhoto.downloadImage(from: items[indexPath.row].profilePhoto ?? "")
        return cell
    }
    
    // - make rows in table view selectable
    // - when one row get selected , go to detail page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         itemToDetail = items[indexPath.row]
        
        performSegue(withIdentifier: "goDetail", sender: self)
        
    }
    
    // send the item to DetailViewController
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
        return 230; //Choose your custom row height
    }
    
    //-----------------------------------------------------------------------------------
    

    override func viewWillAppear(_ animated: Bool) {
        //In order to check if the user is sign in when display the page
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            //If the user is sign in then we hide the sign in option
            if let user = user{
                self.user = user
                //If the user is not sign in then we display the sign in option
            }else{
                print("The user is nil")
            }
        }
        
        // get Info from firebase data base and put in arrayList
        let serviceApi = ItemsServiceApi()
        serviceApi.getAllItemsFrimFireBaseDataBase { (allItems) in
            print("Set the items")
            self.items = allItems
            // sort the array based on time of creation
            self.items.sort(by: { $1.timeOfCreation < $0.timeOfCreation
            })
            self.tableView.reloadData()
        }
    }
    override func viewDidDisappear(_ animated: Bool) { items.removeAll() }
    
    
}







