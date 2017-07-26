//
//  RatingPopUpViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-24.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import FloatRatingView

class RatingPopUpViewController: UIViewController  ,FloatRatingViewDelegate{
    
    weak var delegate : ratingPopUpDelegate?
    var rating : Float?

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var floatingStar: FloatRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Required float rating view params
        self.floatingStar.emptyImage = UIImage(named: "StarEmpty")
        self.floatingStar.fullImage = UIImage(named: "StarFull")
        // Optional params
        self.floatingStar.delegate = self
        self.floatingStar.contentMode = UIViewContentMode.scaleAspectFit
        self.floatingStar.maxRating = 5
        self.floatingStar.minRating = 1
        self.floatingStar.rating = 4
        self.floatingStar.editable = true
        self.floatingStar.halfRatings = true
        self.floatingStar.floatRatings = false
        // make the corner of pop up view circle shape
        popupView.layer.cornerRadius = 20

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating:Float) {
        self.rating = self.floatingStar.rating
    }
    

    @IBOutlet weak var closeBtn: UIButton!
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneBtton(_ sender: UIButton) {
        
        self.delegate?.upDateRating(newRating: rating!)
        dismiss(animated: true, completion: nil)
    }
}
