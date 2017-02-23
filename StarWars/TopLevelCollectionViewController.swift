//
//  EntityCollectionViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/28/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import ChameleonFramework

private let reuseIdentifier = "TopLevelCell"

class TopLevelCollectionViewController: UICollectionViewController {
    let entities = DataRepo.getAllTopLevelItems()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entities.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TopLevelCollectionViewCell
        
        let entity = getEntity(forIndexPath: indexPath)
    
        // Configure the cell
        cell.name.text = entity.getName()
        cell.image.image = UIImage(named: entity.type.getImageName())
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entity = getEntity(forIndexPath: indexPath)
        
        let itemsVC = self.storyboard?.instantiateViewController(withIdentifier: ItemsCollectionViewController.storyboardIdentifier()) as! ItemsCollectionViewController
        
        itemsVC.entity = entity
        
        navigationController?.pushViewController(itemsVC, animated: true)
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
    
    func getEntity(forIndexPath indexPath: IndexPath) -> TopLevelItem{
        return entities[indexPath.row]
    }

}
