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


class ItemsCollectionViewController: UICollectionViewController{
    var entity: TopLevelItem?
    var items: [Displayable]?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let entity = entity{
            self.title = entity.getName()
            
            DataRepo.getAllSwapiItems(type: entity.type){ items in
                self.items = items
                self.collectionView?.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            
            if let imageUrl = item.getImageLink(){ //We already have an image link
                cell.image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: placeholderId))
            }
            else{ //Time to go get the image link
                cell.image.image = UIImage(named: placeholderId) //Put a placeholder there for now
                DataRepo.getImageUrl(name: item.getName(), scaledDown: true){ imageUrl in
                    let item = self.items?[indexPath.row]
                    
                    if let imageUrl = imageUrl, var item = item{
                        item.setImageLink(link: imageUrl)
                        self.items?[indexPath.row] = item
                        collectionView.reloadItems(at: [indexPath]) //Only reload the one we just changed
                    }
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var nextVC: VCWithName
        if let entity = entity{
            switch entity.type{
            case .people:
                nextVC = storyboard?.instantiateViewController(withIdentifier: "PersonDetailView") as! VCWithName
            case .planets:
                nextVC = storyboard?.instantiateViewController(withIdentifier: "PlanetDetailView") as! VCWithName
            case .vehicles:
                nextVC = storyboard?.instantiateViewController(withIdentifier: "VehicleDetailView") as! VCWithName
            case .starships:
                nextVC = storyboard?.instantiateViewController(withIdentifier: "StarshipDetailView") as! VCWithName
            case .species:
                nextVC = storyboard?.instantiateViewController(withIdentifier: "SpeciesDetailView") as! VCWithName
            case .films:
                nextVC = storyboard?.instantiateViewController(withIdentifier: "FilmDetailView") as! VCWithName
            }
            
            if let item = items?[indexPath.row]{
                nextVC.name = item.getName()
                nextVC.id = item.getId()
                navigationController?.pushViewController(nextVC as! UIViewController, animated: true)
            }
        }
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.white
    }
    
    //View that instantiates this will use this method to get the right one
    static func storyboardIdentifier() -> String{
        return storyboardId
    }
}
