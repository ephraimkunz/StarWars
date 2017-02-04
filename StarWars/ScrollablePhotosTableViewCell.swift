//
//  ScrollablePhotosTableViewCell.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/2/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit

class ScrollablePhotosTableViewCell: UITableViewCell {
    @IBOutlet private weak var outerView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 5
        outerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        outerView.layer.shadowOpacity = 0.2;
        outerView.layer.shadowRadius = 1.0;
        
        
        
        let photoCell = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        collectionView.register(photoCell, forCellWithReuseIdentifier: "PhotoCell")
    }
    
    //Give a way to set the delegate and datasource of the collection view
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDataSource & UICollectionViewDelegate>(dataSourceDelegate: D, forRow row: Int){
        collectionView.dataSource = dataSourceDelegate
        collectionView.delegate = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
