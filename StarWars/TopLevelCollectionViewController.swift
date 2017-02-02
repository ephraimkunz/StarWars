//
//  EntityCollectionViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/28/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "TopLevelCell"
private let placeholderId = "GenericImagePlaceholder"

class TopLevelCollectionViewController: UICollectionViewController {
    let entities = DataRepo.getAllTopLevelItems()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
        return 1;
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return entities.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TopLevelCollectionViewCell
        
        let entity = getEntity(forIndexPath: indexPath)
    
        // Configure the cell
        cell.name.text = entity.getName()
        cell.image.image = UIImage(named: placeholderId)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entity = getEntity(forIndexPath: indexPath)
        
        let itemsVC = self.storyboard?.instantiateViewController(withIdentifier: ItemsCollectionViewController.storyboardIdentifier()) as! ItemsCollectionViewController
        
        itemsVC.entity = entity as? TopLevelItem //Cast here to be able to access entityType information later
        
        navigationController?.pushViewController(itemsVC, animated: true)
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.blue
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.white
    }
    
    func getEntity(forIndexPath indexPath: IndexPath) -> Displayable{
        return entities[indexPath.row]
    }

}
