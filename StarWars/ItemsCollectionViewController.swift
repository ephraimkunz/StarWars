//
//  ItemsCollectionViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/28/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import SDWebImage

private let storyboardId = "ItemsCVC"
private let reuseIdentifier = "ItemCell"
private let placeholderId = "GenericImagePlaceholder"
private let imageDimension = 300 //Image dimension to scale the massive images from the server to


class ItemsCollectionViewController: UICollectionViewController, SDWebImageManagerDelegate{
    var entity: TopLevelItem?
    var items: [Displayable]?

    override func viewDidLoad() {
        super.viewDidLoad()
        SDWebImageManager.shared().delegate = self

        if let entity = entity{
            self.title = entity.getName()
            
            DataRepo.getAllSwapiItems(type: entity.type){ items in
                self.items = items
                self.collectionView?.reloadData()
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let items = items{
            return items.count
        }
        
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    
        // Configure the cell
        if let item = items?[indexPath.row]{
            cell.name.text = item.getName()
            
            if let imageUrl = item.getImageLink(){
                cell.image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: placeholderId))
            }
            else{
                cell.image.image = UIImage(named: placeholderId) //Put a placeholder there for now
                DataRepo.getImageUrl(name: item.getName()){ imageUrl in
                    let item = self.items?[indexPath.row]
                    
                    if let imageUrl = imageUrl, var item = item{
                        item.setImageLink(link: imageUrl)
                        self.items?[indexPath.row] = item
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    static func storyboardIdentifier() -> String{
        return storyboardId
    }
    
    func imageManager(_ imageManager: SDWebImageManager!, transformDownloadedImage image: UIImage!, with imageURL: URL!) -> UIImage! {
        let image = DataUtilities.resizeImage(image: image, targetSize: CGSize(width: imageDimension, height: imageDimension))
        return image
    }

}
