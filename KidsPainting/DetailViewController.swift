//
//  DetailViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-18.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase



class DetailViewController: UIViewController ,FloatRatingViewDelegate, ratingPopUpDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: Outlets
    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var giveRatingOutlet: UIButton!
    @IBOutlet weak var priceImg: UILabel!
    @IBOutlet weak var nameOfAuther: UILabel!
    @IBOutlet weak var nameOfRticleDetail: UILabel!
    @IBOutlet weak var starRatingDetail: FloatRatingView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buyButton: UIButton!
    
    //    // Review Outlet
//    @IBOutlet weak var itemReview: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func writeReviewBtn(_ sender: UIButton) {
        
        let reviewViewController = UIStoryboard(name: "Review", bundle: nil).instantiateViewController(withIdentifier: "Review") as! ReviewViewController
        reviewViewController.currentItem = itemFromMain
        self.show(reviewViewController, sender: self)
 
    }
   
    
    @IBAction func buyBtn(_ sender: UIButton) {
        self.alert(title: "warning", message: " This function have not been implemented yet")
    }
    //MARK: Attributes
    var itemFromMain : Item! = nil
    var lastRating : Float! = nil
    
    // ArrayList of Reviews to feed Review TableView
    var itemReviewArray = [Review]()
    
    var newRating : Double?
    
    //MARK: Default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Initialize tableViewReviews
        tableView.delegate = self
        tableView.dataSource = self
        configurationForRating()
        // populate labels and image in this page
        detailImg.downloadImage(from: itemFromMain.pathToImage)
        self.priceImg.text = String(itemFromMain.price)
        self.nameOfAuther.text = itemFromMain.author
        self.nameOfRticleDetail.text = itemFromMain.nameOfArticle
        // user just can rate other items (not his items)
        if String((Auth.auth().currentUser?.uid)!) == itemFromMain.userID {
            giveRatingOutlet.isEnabled = false
        }
        self.itemDescription.text = itemFromMain.itemDescription
        self.buyButton.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Custom Methods
    override func viewWillAppear(_ animated: Bool) {
        
        //TODO: Update itemReview textView with new review
        connectToDBandQueryItemReviews{() in
            self.itemReviewArray.sort(by: {$1.reviewDate < $0.reviewDate})
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source ------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("This is the number of sections 1")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("This is the number of items \(itemReviewArray.count)")
        return itemReviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) 
        cell.textLabel?.text  = self.itemReviewArray[indexPath.row].reviewString
        cell.detailTextLabel?.text = self.itemReviewArray[indexPath.row].displayName
        
    
        return cell
    }
    //-----------------------------------------------------------------------------------------------------------------

    
    
    // MARK: Query from databse for current item reviews --------------------------------------------------------------
    func connectToDBandQueryItemReviews(updateReviewTableViewWhenDownloadingReviewsIsDoneCompletion : @escaping () -> Void){
        // 1- Get the current user uid
        _ = Auth.auth().currentUser!.uid
        
        // 2- Create a reference to backend database
        let ref = Database.database().reference()
        
        ref.child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            // All values is array of dictionary
            guard let allReviews = value?.allValues as? [[String:String]] else {return}
            //print("This is allReviews: \(String(describing: allReviews))")
            
            var allItemReviews = ""
            self.itemReviewArray.removeAll()
            for currentReviewDictionary in allReviews {
                
                if currentReviewDictionary["itemPostID"] == self.itemFromMain.postID{
                    
                    
                    let displayName = currentReviewDictionary["displayName"]! as String
                    let reviewString = currentReviewDictionary["reviewString"]!
                    let reviewDateString = currentReviewDictionary["reviewDate"]! as String
                    let reviewDate = Item.dateFromString(reviewDateString)!
                    
                    
                    // Create a review object
                    let currentReviewObject = Review(displayName: displayName, reviewString: reviewString, reviewDate : reviewDate)
                    
                    // Add review object to review tableView Array
                    self.itemReviewArray.append(currentReviewObject)
                    
                    
                    
                    //print("This is itemReviewArray: \(self.itemReviewArray.description)")
                    // Update review textView ------------------------------------------------------------------------------------
                    allItemReviews = allItemReviews + reviewString + "\n" + "-----------------------------------------------------"
                    //------------------------------------------------------------------------------------------------------------
                    //print("\n ------------ Item reviews in detail page: ")
                    
                    
                }
            }
            updateReviewTableViewWhenDownloadingReviewsIsDoneCompletion()
            print(allItemReviews)
            //self.itemReview.text = allItemReviews
        }) { (error) in
            print(error.localizedDescription)
        }
        ref.removeAllObservers()
    }
    //---------------------------------------------------------------------------------------------------------------------
    
    
    
    
    // MARK: Rating -------------------------------------------------------------------------------------------------------
    func configurationForRating() {
        // Required float rating view params
        self.starRatingDetail.emptyImage = UIImage(named: "StarEmpty")
        self.starRatingDetail.fullImage = UIImage(named: "StarFull")
        
        // Optional params
        self.starRatingDetail.delegate = self
        self.starRatingDetail.contentMode = UIViewContentMode.scaleAspectFit
        self.starRatingDetail.maxRating = 5
        self.starRatingDetail.minRating = 1
        self.starRatingDetail.rating = itemFromMain.itemRating
        self.starRatingDetail.editable = false
        self.starRatingDetail.halfRatings = true
        self.starRatingDetail.floatRatings = false
        lastRating = itemFromMain.itemRating

    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating:Float) {
    }
    
    // - get the itemRating for this post and calculate new rating for this post
    // increate number of user who did rating
    func upDateRating(newRating: Float) {
        self.itemFromMain.numberOfPeopleWhoDidRating =
            self.itemFromMain.numberOfPeopleWhoDidRating + 1
        var calculatedRating : Float {
            get {
                let numberOfPeople = itemFromMain.numberOfPeopleWhoDidRating
                let totalRating = ((lastRating * Float(numberOfPeople - 1)) + newRating)
                let finalRating = totalRating / Float(numberOfPeople)
                return finalRating
            }
        }
        let calRating = calculatedRating
        
        // - update the itemRating for this post
        let service = ItemsServiceApi()
        service.updateRatingOfItem(postKey: itemFromMain.postID, rating: calRating, numOfPeople: self.itemFromMain.numberOfPeopleWhoDidRating)
        // - update starRatingDetail in the view
        self.starRatingDetail.rating = calRating
        lastRating = calRating
        
    }
    //---------------------------------------------------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToPop" {
            let vc = segue.destination as! RatingPopUpViewController
            vc.delegate = self
        }
            
        // TODO: Need to be updated to go to new storyboard
            
        
        // Pass itemFromMain to review page  ==============================================================================
        
//        if  == "Review" {
//            
//            let vc = segue.destination as! ReviewViewController
//            //vc.currentItem = itemFromMain
//            
//            //let vc = UIStoryboard(name: "Review", bundle: nil).instantiateViewController(withIdentifier: "Review")
//            //self.present(vc, animated: true, completion: nil)
//        }
    }   //=================================================================================================================

}


protocol ratingPopUpDelegate : class {
    func upDateRating(newRating: Float)
}


