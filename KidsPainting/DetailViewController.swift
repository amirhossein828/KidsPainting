//
//  DetailViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-18.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController ,FloatRatingViewDelegate,ratingPopUpDelegate{
    
    @IBOutlet weak var detailImg: UIImageView!
    
    
    @IBOutlet weak var giveRatingOutlet: UIButton!
    
    @IBOutlet weak var priceImg: UILabel!
    
    @IBOutlet weak var nameOfAuther: UILabel!
    
    @IBOutlet weak var nameOfRticleDetail: UILabel!
    
    @IBOutlet weak var starRatingDetail: FloatRatingView!
    
    var itemFromMain : Item! = nil
    var newRating : Double?

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
        
        
        detailImg.downloadImage(from: itemFromMain.pathToImage)
//        downloadImageFrom(itemFromMain.pathToImage) { (data) in
//            if let data = data{
//                self.detailImg.image = UIImage(data: data)
//            }
//        }
        self.priceImg.text = String(itemFromMain.price)
        self.nameOfAuther.text = itemFromMain.author
        self.nameOfRticleDetail.text = itemFromMain.nameOfArticle
        // user just can rate other items (not his items)
        if String((Auth.auth().currentUser?.uid)!) == itemFromMain.userID {
            giveRatingOutlet.isEnabled = false
        }
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating:Float) {
        // self.resultlabel.text = NSString(format: "%.2f", self.floatingStar.rating) as String
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
    func upDateRating(newRating: Float) {
        
        // - get the itemRating for this post and calculate new rating for this post
        // increate number of user who did rating
        self.itemFromMain.numberOfPeopleWhoDidRating =
            self.itemFromMain.numberOfPeopleWhoDidRating + 1
        var calculatedRating : Float {
            get {
                return ((itemFromMain.itemRating + newRating) / Float(itemFromMain.numberOfPeopleWhoDidRating))
            }
        }
        // - update the itemRating for this post
        let service = ItemsServiceApi()
        service.updateRatingOfItem(postKey: itemFromMain.postID, rating: calculatedRating, numOfPeople: self.itemFromMain.numberOfPeopleWhoDidRating)
        // - update starRatingDetail in the view
        self.starRatingDetail.rating = calculatedRating
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToPop" {
            let vc = segue.destination as! RatingPopUpViewController
            vc.delegate = self
            
        }
    }

}


protocol ratingPopUpDelegate : class {
    func upDateRating(newRating: Float)
}


