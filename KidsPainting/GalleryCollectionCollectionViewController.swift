 //
//  GalleryCollectionCollectionViewController.swift
//  KidsPainting
//
//  Created by seyedamirhossein hashemi on 2017-07-16.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class GalleryCollectionCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    var imageArray = [UIImage]()
    var index : Int?
    
    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        grabPhotos()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    // MARK: UICollectionViewDataSource ----------------------------------------------

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imageArray.count
    }
    
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        
        cell.imageView.image = imageArray[indexPath.row]

        return cell
    }
    //--------------------------------------------------------------------------------
     
    
    // Show big presentation of selected image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        print(imageArray.count)
        
        self.bigImage.image = imageArray[indexPath.row]
        index = indexPath.row
        nextButton.isEnabled = true
    }
    
    
    // MARK: Action methods ----------------------------------------------------------
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextBtn(_ sender: UIBarButtonItem) { }
    //--------------------------------------------------------------------------------
    
    
    // Preview large image -----------------------------------------------------------
    func grabPhotos() {
        // PHImageManager provides methods for retrieving or generating preview thumbnails and full-size image
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        let fetchoptions = PHFetchOptions()
        fetchoptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options:  fetchoptions){
            
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    imgManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width : 200,height : 200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                        if let image = image {
                            self.imageArray.append(image)
                            self.collectionView?.reloadData()
                        }
                    })
                }
            }else{
                print("you got no photos")
                self.collectionView?.reloadData()
            }
        }
    }
    //--------------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToNavigationBar" {

            if let vc = segue.destination as? UploadItemViewController {
                 vc.newImage = self.imageArray[index!]
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if imageArray.count > 0 {
        self.bigImage.image = imageArray[0]
        }
    }
 

}
